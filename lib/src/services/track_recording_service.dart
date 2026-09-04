import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:geotracker/src/domain/gps_filter.dart';
import 'package:geotracker/src/domain/session_elapsed.dart';
import 'package:geotracker/src/domain/track_point.dart';
import 'package:geotracker/src/services/geolocation_service.dart';
import 'package:injectable/injectable.dart';

enum RecordingStatus { idle, recording, paused, finished }

/// Immutable snapshot of an in-memory recording session.
class RecordingSnapshot {
  const RecordingSnapshot({
    this.status = RecordingStatus.idle,
    this.points = const [],
    this.startedAt,
    this.finishedAt,
    this.latestPosition,
    this.elapsedTime = Duration.zero,
  });

  final RecordingStatus status;
  final List<TrackPoint> points;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final Duration elapsedTime;

  /// Latest raw GPS sample (may differ from last filtered track point).
  final TrackPoint? latestPosition;

  TrackPoint? get lastAcceptedPoint => points.isEmpty ? null : points.last;
}

@LazySingleton()
class TrackRecordingService {
  TrackRecordingService(this._geolocationService);

  final GeolocationService _geolocationService;
  final GpsFilter _filter = const GpsFilter();
  final StreamController<RecordingSnapshot> _snapshotsController =
      StreamController<RecordingSnapshot>.broadcast();

  StreamSubscription<Position>? _positionSubscription;
  RecordingSnapshot _snapshot = const RecordingSnapshot();
  Duration _totalPausedDuration = Duration.zero;
  DateTime? _pauseStartedAt;
  DateTime? _finishedAt;

  Stream<RecordingSnapshot> get snapshots => _snapshotsController.stream;
  RecordingSnapshot get currentSnapshot => _snapshot;

  Future<void> start() async {
    if (_snapshot.status == RecordingStatus.recording) {
      return;
    }

    final hasPermission = await _geolocationService.hasPermissionsAsync();
    if (!hasPermission) {
      await _geolocationService.requestPermissionsAsync();
    }

    final isNewSession = _snapshot.status == RecordingStatus.idle;
    if (isNewSession) {
      _totalPausedDuration = Duration.zero;
      _pauseStartedAt = null;
      _finishedAt = null;
    }

    final startedAt = isNewSession
        ? DateTime.now()
        : (_snapshot.startedAt ?? DateTime.now());

    _emitSnapshot(
      status: RecordingStatus.recording,
      points: _snapshot.points,
      startedAt: startedAt,
      latestPosition: _snapshot.latestPosition,
    );
    await _ensurePositionStream();
  }

  Future<void> resume() async {
    if (_snapshot.status != RecordingStatus.paused) {
      return;
    }

    if (_pauseStartedAt != null) {
      _totalPausedDuration += DateTime.now().difference(_pauseStartedAt!);
      _pauseStartedAt = null;
    }
    _finishedAt = null;

    _emitSnapshot(
      status: RecordingStatus.recording,
      points: _snapshot.points,
      startedAt: _snapshot.startedAt,
      latestPosition: _snapshot.latestPosition,
    );
    await _ensurePositionStream();
  }

  void pause() {
    if (_snapshot.status != RecordingStatus.recording) {
      return;
    }

    _pauseStartedAt = DateTime.now();
    _emitSnapshot(
      status: RecordingStatus.paused,
      points: _snapshot.points,
      startedAt: _snapshot.startedAt,
      latestPosition: _snapshot.latestPosition,
    );
  }

  void finish() {
    if (_snapshot.status == RecordingStatus.idle) {
      return;
    }

    _finishedAt = DateTime.now();
    _emitSnapshot(
      status: RecordingStatus.finished,
      points: _snapshot.points,
      startedAt: _snapshot.startedAt,
      latestPosition: _snapshot.latestPosition,
    );
  }

  void reset() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _totalPausedDuration = Duration.zero;
    _pauseStartedAt = null;
    _finishedAt = null;
    _snapshot = const RecordingSnapshot();
    if (!_snapshotsController.isClosed) {
      _snapshotsController.add(_snapshot);
    }
  }

  void dispose() {
    _positionSubscription?.cancel();
    _snapshotsController.close();
  }

  Future<void> _ensurePositionStream() async {
    if (_positionSubscription != null) {
      return;
    }
    _positionSubscription = _geolocationService.watchPosition().listen(
      _onPosition,
      onError: (_) {},
    );
  }

  void _onPosition(Position position) {
    final trackPoint = _positionToTrackPoint(position);
    final isRecording = _snapshot.status == RecordingStatus.recording;
    var points = _snapshot.points;

    if (isRecording &&
        _filter.shouldAccept(trackPoint, _snapshot.lastAcceptedPoint)) {
      points = [...points, trackPoint];
    }

    _emitSnapshot(
      status: _snapshot.status,
      points: points,
      startedAt: _snapshot.startedAt,
      latestPosition: trackPoint,
    );
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
    final elapsedTime = SessionElapsed.compute(
      startedAt: resolvedStartedAt,
      totalPausedDuration: _totalPausedDuration,
      pauseStartedAt: _pauseStartedAt,
      finishedAt: _finishedAt,
      now: DateTime.now(),
      isIdle: status == RecordingStatus.idle,
      isPaused: status == RecordingStatus.paused,
      isFinished: status == RecordingStatus.finished,
    );

    _snapshot = RecordingSnapshot(
      status: status,
      points: resolvedPoints,
      startedAt: resolvedStartedAt,
      finishedAt: _finishedAt,
      latestPosition: resolvedLatest,
      elapsedTime: elapsedTime,
    );

    if (!_snapshotsController.isClosed) {
      _snapshotsController.add(_snapshot);
    }
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
