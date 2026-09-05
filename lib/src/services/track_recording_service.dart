import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:geotracker/src/core/app_log.dart';
import 'package:geotracker/src/data/repositories/track_repository.dart';
import 'package:geotracker/src/domain/gps_filter.dart';
import 'package:geotracker/src/domain/marker.dart';
import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/recording_draft.dart';
import 'package:geotracker/src/domain/session_elapsed.dart';
import 'package:geotracker/src/domain/track_calculations.dart';
import 'package:geotracker/src/domain/track_point.dart';
import 'package:geotracker/src/services/geolocation_service.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

enum RecordingStatus { idle, recording, paused, finished }

class RecordingSnapshot {
  const RecordingSnapshot({
    this.status = RecordingStatus.idle,
    this.sessionId,
    this.points = const [],
    this.startedAt,
    this.finishedAt,
    this.latestPosition,
    this.elapsedTime = Duration.zero,
    this.markers = const [],
    this.pauseIntervals = const [],
  });

  final RecordingStatus status;
  final String? sessionId;
  final List<TrackPoint> points;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final Duration elapsedTime;
  final List<Marker> markers;
  final List<PauseInterval> pauseIntervals;
  final TrackPoint? latestPosition;

  TrackPoint? get lastAcceptedPoint => points.isEmpty ? null : points.last;
}

@LazySingleton()
class TrackRecordingService {
  TrackRecordingService(this._geolocationService, this._trackRepository);

  final GeolocationService _geolocationService;
  final TrackRepository _trackRepository;
  final GpsFilter _filter = const GpsFilter();
  final Uuid _uuid = const Uuid();
  final StreamController<RecordingSnapshot> _snapshotsController =
      StreamController<RecordingSnapshot>.broadcast();

  StreamSubscription<Position>? _positionSubscription;
  RecordingSnapshot _snapshot = const RecordingSnapshot();
  Duration _totalPausedDuration = Duration.zero;
  DateTime? _pauseStartedAt;
  DateTime? _finishedAt;
  List<Marker> _markers = const [];
  List<PauseInterval> _pauseIntervals = const [];
  String? _sessionId;
  int _persistedPointCount = 0;
  bool _checkpointInFlight = false;
  bool _checkpointQueued = false;
  bool _checkpointReplaceMarkersQueued = false;

  Stream<RecordingSnapshot> get snapshots => _snapshotsController.stream;

  RecordingSnapshot get currentSnapshot {
    if (_snapshot.status == RecordingStatus.idle ||
        _snapshot.status == RecordingStatus.finished ||
        _snapshot.status == RecordingStatus.paused) {
      return _snapshot;
    }
    return _copySnapshotWithElapsed(_snapshot, DateTime.now());
  }

  String? get sessionId => _sessionId;

  Future<void> start() async {
    if (_snapshot.status == RecordingStatus.recording) {
      return;
    }

    await _geolocationService.requestAlwaysPermission();

    final isNewSession = _snapshot.status == RecordingStatus.idle;
    if (isNewSession) {
      _totalPausedDuration = Duration.zero;
      _pauseStartedAt = null;
      _finishedAt = null;
      _markers = const [];
      _pauseIntervals = const [];
      _persistedPointCount = 0;
      _sessionId = _uuid.v4();
    }

    final startedAt = isNewSession
        ? DateTime.now()
        : (_snapshot.startedAt ?? DateTime.now());

    if (isNewSession && _sessionId != null) {
      await _trackRepository.createDraft(
        id: _sessionId!,
        name: 'Recording $startedAt',
        startedAt: startedAt,
        recordingStatus: RecordingStatus.recording.name,
      );
    }

    _emitSnapshot(
      status: RecordingStatus.recording,
      points: _snapshot.points,
      startedAt: startedAt,
      latestPosition: _snapshot.latestPosition,
    );
    await _checkpoint();
    await _ensurePositionStream();
    AppLog.i(
      'Recording start session=$_sessionId new=$isNewSession '
      'points=${_snapshot.points.length}',
    );
  }

  Future<void> resume() async {
    if (_snapshot.status != RecordingStatus.paused) {
      return;
    }

    await _geolocationService.requestAlwaysPermission();
    _finalizeOpenPause(DateTime.now());
    _finishedAt = null;
    _emitSnapshot(
      status: RecordingStatus.recording,
      points: _snapshot.points,
      startedAt: _snapshot.startedAt,
      latestPosition: _snapshot.latestPosition,
    );
    await _checkpoint();
    await _ensurePositionStream();
    AppLog.i(
      'Recording resume session=$_sessionId points=${_snapshot.points.length}',
    );
  }

  Future<void> pause() async {
    if (_snapshot.status != RecordingStatus.recording) {
      return;
    }

    await _cancelPositionStream();
    _pauseStartedAt = DateTime.now();
    _emitSnapshot(
      status: RecordingStatus.paused,
      points: _snapshot.points,
      startedAt: _snapshot.startedAt,
      latestPosition: _snapshot.latestPosition,
    );
    await _checkpoint();
    AppLog.i(
      'Recording pause session=$_sessionId points=${_snapshot.points.length}',
    );
  }

  Future<void> finish() async {
    if (_snapshot.status == RecordingStatus.idle) {
      return;
    }

    await _cancelPositionStream();
    _finishedAt = DateTime.now();
    _finalizeOpenPause(_finishedAt!);
    _emitSnapshot(
      status: RecordingStatus.finished,
      points: _snapshot.points,
      startedAt: _snapshot.startedAt,
      latestPosition: _snapshot.latestPosition,
    );
    await _checkpoint();
    AppLog.i(
      'Recording finish session=$_sessionId points=${_snapshot.points.length} '
      'elapsed=${_snapshot.elapsedTime.inSeconds}s',
    );
  }

  Future<void> addMarker(Marker marker) async {
    if (_snapshot.status == RecordingStatus.idle) {
      return;
    }
    _markers = [..._markers, marker];
    _emitSnapshot(
      status: _snapshot.status,
      points: _snapshot.points,
      startedAt: _snapshot.startedAt,
      latestPosition: _snapshot.latestPosition,
    );
    await _checkpoint(replaceMarkers: true);
  }

  Future<void> reset({bool discardDraft = false}) async {
    final id = _sessionId;
    await _cancelPositionStream();
    _totalPausedDuration = Duration.zero;
    _pauseStartedAt = null;
    _finishedAt = null;
    _markers = const [];
    _pauseIntervals = const [];
    _persistedPointCount = 0;
    _sessionId = null;
    _snapshot = const RecordingSnapshot();
    if (!_snapshotsController.isClosed) {
      _snapshotsController.add(_snapshot);
    }
    if (discardDraft && id != null) {
      await _trackRepository.discardDraft(id);
    }
  }

  Future<void> restoreFromDraft(RecordingDraft draft) async {
    await _cancelPositionStream();

    final status = _statusFromName(draft.recordingStatus);
    if (status == null || status == RecordingStatus.idle) {
      return;
    }

    _sessionId = draft.track.id;
    _markers = List<Marker>.from(draft.track.markers);
    _pauseIntervals = List<PauseInterval>.from(draft.pauseIntervals);
    _totalPausedDuration = draft.totalPausedDuration;
    _pauseStartedAt = draft.openPauseStartedAt;
    _finishedAt = status == RecordingStatus.finished
        ? _finishedAtFromDraft(draft)
        : null;
    _persistedPointCount = draft.track.points.length;

    _emitSnapshot(
      status: status,
      points: draft.track.points,
      startedAt: draft.track.startedAt,
      latestPosition: draft.track.points.isEmpty
          ? null
          : draft.track.points.last,
    );

    if (status == RecordingStatus.recording) {
      await _geolocationService.requestAlwaysPermission();
      await _ensurePositionStream();
    }
    AppLog.i(
      'Recording restore session=$_sessionId status=${status.name} '
      'points=${draft.track.points.length}',
    );
  }

  void dispose() {
    _positionSubscription?.cancel();
    _snapshotsController.close();
  }

  DateTime _finishedAtFromDraft(RecordingDraft draft) {
    if (draft.track.finishedAt != null) {
      return draft.track.finishedAt!;
    }
    return draft.track.startedAt
        .add(draft.track.duration)
        .add(draft.totalPausedDuration);
  }

  RecordingStatus? _statusFromName(String name) {
    for (final value in RecordingStatus.values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }

  void _finalizeOpenPause(DateTime endedAt) {
    if (_pauseStartedAt == null) {
      return;
    }

    _totalPausedDuration += endedAt.difference(_pauseStartedAt!);
    final position = _snapshot.lastAcceptedPoint ?? _snapshot.latestPosition;
    if (position != null && !endedAt.isBefore(_pauseStartedAt!)) {
      _pauseIntervals = [
        ..._pauseIntervals,
        PauseInterval(
          startedAt: _pauseStartedAt!,
          finishedAt: endedAt,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      ];
    }
    _pauseStartedAt = null;
  }

  Future<void> _ensurePositionStream() async {
    if (_positionSubscription != null) {
      return;
    }
    AppLog.i('GPS stream subscribe session=$_sessionId');
    _positionSubscription = _geolocationService.watchRecordingPosition().listen(
      _onPosition,
      onError: (Object error, StackTrace stackTrace) {
        AppLog.e('GPS stream error', error, stackTrace);
      },
    );
  }

  Future<void> _cancelPositionStream() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _onPosition(Position position) {
    final trackPoint = _positionToTrackPoint(position);
    final isRecording = _snapshot.status == RecordingStatus.recording;
    var points = _snapshot.points;
    var acceptedNew = false;

    if (isRecording &&
        _filter.shouldAccept(trackPoint, _snapshot.lastAcceptedPoint)) {
      points = [...points, trackPoint];
      acceptedNew = true;
    }

    _emitSnapshot(
      status: _snapshot.status,
      points: points,
      startedAt: _snapshot.startedAt,
      latestPosition: trackPoint,
    );

    if (acceptedNew) {
      unawaited(_checkpoint());
    }
  }

  Future<void> _checkpoint({bool replaceMarkers = false}) async {
    final id = _sessionId;
    if (id == null || _snapshot.status == RecordingStatus.idle) {
      return;
    }

    if (_checkpointInFlight) {
      _checkpointQueued = true;
      if (replaceMarkers) {
        _checkpointReplaceMarkersQueued = true;
      }
      return;
    }
    _checkpointInFlight = true;

    var pendingReplaceMarkers = replaceMarkers;
    try {
      do {
        _checkpointQueued = false;
        final shouldReplaceMarkers =
            pendingReplaceMarkers || _checkpointReplaceMarkersQueued;
        pendingReplaceMarkers = false;
        _checkpointReplaceMarkersQueued = false;

        final points = _snapshot.points;
        final newPoints = points.skip(_persistedPointCount).toList();
        if (newPoints.isNotEmpty) {
          await _trackRepository.appendPoints(
            trackId: id,
            points: newPoints,
            startOrderIndex: _persistedPointCount,
          );
          _persistedPointCount = points.length;
        }

        if (shouldReplaceMarkers) {
          await _trackRepository.replaceMarkers(
            trackId: id,
            markers: _markers,
          );
        }

        final distance = TrackCalculations.totalDistanceMeters(points);
        await _trackRepository.updateDraftMeta(
          id: id,
          recordingStatus: _snapshot.status.name,
          pauseIntervals: _pauseIntervals,
          totalPausedDuration: _totalPausedDuration,
          openPauseStartedAt: _pauseStartedAt,
          distanceMeters: distance,
          durationMs: _snapshot.elapsedTime.inMilliseconds,
        );
      } while (_checkpointQueued);
    } catch (_) {
    } finally {
      _checkpointInFlight = false;
    }
  }

  void _emitSnapshot({
    required RecordingStatus status,
    List<TrackPoint>? points,
    DateTime? startedAt,
    TrackPoint? latestPosition,
  }) {
    final resolvedPoints = List<TrackPoint>.unmodifiable(
      points ?? _snapshot.points,
    );
    final resolvedStartedAt = startedAt ?? _snapshot.startedAt;
    final resolvedLatest = latestPosition ?? _snapshot.latestPosition;
    final base = RecordingSnapshot(
      status: status,
      sessionId: _sessionId,
      points: resolvedPoints,
      startedAt: resolvedStartedAt,
      finishedAt: _finishedAt,
      latestPosition: resolvedLatest,
      markers: List<Marker>.unmodifiable(_markers),
      pauseIntervals: List<PauseInterval>.unmodifiable(_pauseIntervals),
    );
    _snapshot = _copySnapshotWithElapsed(base, DateTime.now());

    if (!_snapshotsController.isClosed) {
      _snapshotsController.add(_snapshot);
    }
  }

  RecordingSnapshot _copySnapshotWithElapsed(
    RecordingSnapshot snapshot,
    DateTime now,
  ) {
    final elapsedTime = SessionElapsed.compute(
      startedAt: snapshot.startedAt,
      totalPausedDuration: _totalPausedDuration,
      pauseStartedAt: _pauseStartedAt,
      finishedAt: _finishedAt,
      now: now,
      isIdle: snapshot.status == RecordingStatus.idle,
      isPaused: snapshot.status == RecordingStatus.paused,
      isFinished: snapshot.status == RecordingStatus.finished,
    );
    return RecordingSnapshot(
      status: snapshot.status,
      sessionId: snapshot.sessionId,
      points: snapshot.points,
      startedAt: snapshot.startedAt,
      finishedAt: snapshot.finishedAt,
      latestPosition: snapshot.latestPosition,
      elapsedTime: elapsedTime,
      markers: snapshot.markers,
      pauseIntervals: snapshot.pauseIntervals,
    );
  }
}

TrackPoint _positionToTrackPoint(Position position) {
  return TrackPoint(
    latitude: position.latitude,
    longitude: position.longitude,
    altitude: position.altitude,
    speed: position.speed >= 0 ? position.speed : null,
    accuracy: position.accuracy >= 0 ? position.accuracy : null,
    timestamp: position.timestamp,
  );
}
