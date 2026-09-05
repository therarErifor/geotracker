import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' hide Marker;
import 'package:geotracker/src/core/app_log.dart';
import 'package:geotracker/src/data/repositories/track_repository.dart';
import 'package:geotracker/src/domain/marker.dart';
import 'package:geotracker/src/domain/stop_detection.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_calculations.dart';
import 'package:geotracker/src/domain/track_point.dart';
import 'package:geotracker/src/entities/error_type.dart';
import 'package:geotracker/src/entities/tracking_status.dart';
import 'package:geotracker/src/entities/user_position.dart';
import 'package:geotracker/src/services/geolocation_service.dart';
import 'package:geotracker/src/services/track_recording_service.dart';
import 'package:geotracker/src/ui/formatters/track_formatters.dart';
import 'package:geotracker/src/ui/widgets/map_camera_motion.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import 'locate_button_kind.dart';
import 'main_state.dart';

@Injectable()
class MainCubit extends Cubit<MainState> {
  MainCubit(
    GeolocationService geolocationService,
    TrackRecordingService trackRecordingService,
    TrackRepository trackRepository,
  ) : _geolocationService = geolocationService,
      _trackRecordingService = trackRecordingService,
      _trackRepository = trackRepository,
      super(const MainState.init()) {
    _recordingSubscription = _trackRecordingService.snapshots.listen(
      _onRecordingSnapshot,
    );
    init();
  }

  final GeolocationService _geolocationService;
  final TrackRecordingService _trackRecordingService;
  final TrackRepository _trackRepository;
  final MapController _mapController = MapController();
  final Uuid _uuid = const Uuid();

  MapController get mapController => _mapController;

  double _currentZoom = 16;
  late LatLng _currentMapCenter;
  UserPosition? _userPosition;
  TrackingStatus _trackingStatus = TrackingStatus.rest;
  List<TrackPoint> _recordingPoints = const [];
  List<Marker> _trackMarkers = const [];
  double _distanceMeters = 0;
  Duration _elapsedTime = Duration.zero;
  double? _currentSpeedKmh;
  double _averageSpeedKmh = 0;
  bool _cameraFollowEnabled = true;
  String? _saveError;
  String? _sessionInterruptedMessage;
  StreamSubscription<RecordingSnapshot>? _recordingSubscription;
  Timer? _elapsedTimer;

  Future<void> init() async {
    try {
      final hasLocationPermission = await _geolocationService
          .hasPermissionsAsync();
      if (!hasLocationPermission) {
        await _geolocationService.requestPermissionsAsync();
      }
      var result = await _geolocationService.getCurrentPositionAsync();
      if (result.error == ErrorType.permissionDenied) {
        AppLog.w('MainCubit.init permission denied');
        emit(MainState.error(error: result.error!));
        return;
      }
      var position = result.data!;
      _currentMapCenter = LatLng(position.latitude, position.longitude);
      _userPosition = UserPosition(
        currentPosition: _currentMapCenter,
        heading: position.heading,
      );
      await _restoreSessionIfNeeded();
      AppLog.i('MainCubit.init ok lat=${position.latitude} lon=${position.longitude}');
      _emitLoaded();
    } catch (e, stackTrace) {
      AppLog.e('MainCubit.init fallback map center', e, stackTrace);
      _currentMapCenter = LatLng(58.021688, 56.227984);
      await _restoreSessionIfNeeded();
      _emitLoaded(initialZoom: _currentZoom - 14);
    }
  }

  Future<void> _restoreSessionIfNeeded() async {
    final live = _trackRecordingService.currentSnapshot;
    if (live.status != RecordingStatus.idle) {
      _applyRestoredSnapshot(live);
      return;
    }

    final draft = await _trackRepository.getActiveDraft();
    if (draft == null) {
      return;
    }

    if (draft.track.points.isEmpty) {
      await _trackRepository.discardDraft(draft.track.id);
      _sessionInterruptedMessage =
          'Приложение было принудительно остановлено, и записать маршрут не удалось.';
      AppLog.w('Draft discarded empty id=${draft.track.id}');
      return;
    }

    await _trackRecordingService.restoreFromDraft(draft);
    _applyRestoredSnapshot(_trackRecordingService.currentSnapshot);
  }

  void _applyRestoredSnapshot(RecordingSnapshot snapshot) {
    _recordingPoints = snapshot.points;
    _trackMarkers = snapshot.markers;
    _elapsedTime = snapshot.elapsedTime;
    _distanceMeters = TrackCalculations.totalDistanceMeters(snapshot.points);

    _trackingStatus = switch (snapshot.status) {
      RecordingStatus.recording => TrackingStatus.tracking,
      RecordingStatus.paused => TrackingStatus.pause,
      RecordingStatus.finished => TrackingStatus.finish,
      RecordingStatus.idle => TrackingStatus.rest,
    };

    final latest = snapshot.latestPosition ?? snapshot.lastAcceptedPoint;
    if (latest != null) {
      _userPosition = UserPosition(
        currentPosition: LatLng(latest.latitude, latest.longitude),
        heading: _userPosition?.heading ?? 0,
        speed: latest.speed,
      );
      _currentMapCenter = _userPosition!.currentPosition;
      _currentSpeedKmh = latest.speed != null
          ? TrackFormatters.metersPerSecondToKilometersPerHour(latest.speed!)
          : null;
    }

    final averageMetersPerSecond = TrackCalculations.averageSpeedMps(
      _distanceMeters,
      _elapsedTime,
    );
    _averageSpeedKmh = TrackFormatters.metersPerSecondToKilometersPerHour(averageMetersPerSecond);

    if (_trackingStatus == TrackingStatus.tracking) {
      _cameraFollowEnabled = true;
      _startElapsedTimer();
    } else {
      _stopElapsedTimer();
    }
  }

  void _onRecordingSnapshot(RecordingSnapshot snapshot) {
    if (_trackingStatus == TrackingStatus.rest &&
        snapshot.status == RecordingStatus.idle) {
      return;
    }

    _recordingPoints = snapshot.points;
    _trackMarkers = snapshot.markers;
    _elapsedTime = snapshot.elapsedTime;
    _distanceMeters = TrackCalculations.totalDistanceMeters(snapshot.points);

    final latest = snapshot.latestPosition;
    if (latest != null) {
      _userPosition = UserPosition(
        currentPosition: LatLng(latest.latitude, latest.longitude),
        heading: _userPosition?.heading ?? 0,
        speed: latest.speed,
      );
      _currentSpeedKmh = latest.speed != null
          ? TrackFormatters.metersPerSecondToKilometersPerHour(latest.speed!)
          : null;
    }

    final averageMetersPerSecond = TrackCalculations.averageSpeedMps(
      _distanceMeters,
      _elapsedTime,
    );
    _averageSpeedKmh = TrackFormatters.metersPerSecondToKilometersPerHour(averageMetersPerSecond);

    if (_trackingStatus == TrackingStatus.tracking && _cameraFollowEnabled) {
      _followUserPosition();
    }

    _emitLoaded();
  }

  void onMapCameraChanged(MapCamera camera, bool hasGesture) {
    _currentMapCenter = camera.center;
    _currentZoom = camera.zoom;

    if (hasGesture) {
      _cameraFollowEnabled = false;
      _emitLoaded();
    }
  }

  void findMe() async {
    try {
      final result = await _geolocationService.getCurrentPositionAsync();

      if (result.data != null) {
        var position = result.data!;

        _userPosition = UserPosition(
          currentPosition: LatLng(position.latitude, position.longitude),
          heading: position.heading,
        );
        _cameraFollowEnabled = true;
        _followUserPosition(animated: true);
      }
      if (result.error == ErrorType.permissionDenied) {
        emit(MainState.error(error: result.error!));
        return;
      }
      _emitLoaded();
    } catch (e) {
      _emitLoaded();
    }
  }

  void recenterCamera() {
    _cameraFollowEnabled = true;
    _followUserPosition(animated: true);
    _emitLoaded();
  }

  void zoomIn() {
    _currentZoom = _currentZoom + 0.6;
    moveMapCamera(_mapController, _currentMapCenter, _currentZoom);
  }

  void zoomOut() {
    _currentZoom = _currentZoom - 0.6;
    moveMapCamera(_mapController, _currentMapCenter, _currentZoom);
  }

  Future<void> tracking() async {
    if (_trackingStatus == TrackingStatus.pause) {
      await _trackRecordingService.resume();
    } else {
      await _trackRecordingService.start();
    }
    _trackingStatus = TrackingStatus.tracking;
    _cameraFollowEnabled = true;
    _saveError = null;
    _startElapsedTimer();
    _emitLoaded();
  }

  Future<void> pauseTracking() async {
    await _trackRecordingService.pause();
    _trackingStatus = TrackingStatus.pause;
    _elapsedTime = _trackRecordingService.currentSnapshot.elapsedTime;
    _stopElapsedTimer();
    _emitLoaded();
  }

  Future<void> finishTracking() async {
    await _trackRecordingService.finish();
    _trackingStatus = TrackingStatus.finish;
    _elapsedTime = _trackRecordingService.currentSnapshot.elapsedTime;
    _stopElapsedTimer();
    _emitLoaded();
  }

  Future<void> saveTrack() async {
    final snapshot = _trackRecordingService.currentSnapshot;
    final startedAt = snapshot.startedAt;
    final sessionId = snapshot.sessionId;
    if (startedAt == null || sessionId == null || snapshot.points.isEmpty) {
      _saveError = 'Недостаточно данных для сохранения маршрута';
      _emitLoaded();
      return;
    }

    final duration = snapshot.elapsedTime;
    final distance = TrackCalculations.totalDistanceMeters(snapshot.points);
    final stops = const StopDetection().detect(
      points: snapshot.points,
      pauseIntervals: snapshot.pauseIntervals,
    );
    final stoppedDuration = StopDetection.totalDuration(stops);
    var movingDuration = duration - stoppedDuration;
    if (movingDuration.isNegative) {
      movingDuration = Duration.zero;
    }
    final track = Track(
      id: sessionId,
      name: TrackFormatters.defaultTrackName(startedAt),
      startedAt: startedAt,
      finishedAt: snapshot.finishedAt ?? DateTime.now(),
      duration: duration,
      movingDuration: movingDuration,
      stoppedDuration: stoppedDuration,
      distanceMeters: distance,
      averageSpeedMps: TrackCalculations.averageSpeedMps(distance, duration),
      maxSpeedMps: TrackCalculations.maxSpeedMps(snapshot.points),
      elevationGainMeters: TrackCalculations.elevationGainMeters(
        snapshot.points,
      ),
      points: List.unmodifiable(snapshot.points),
      stops: stops,
      markers: List.unmodifiable(snapshot.markers),
    );

    try {
      await _trackRepository.finalizeTrack(track);
      await _trackRecordingService.reset();
      _resetRecordingUiState();
      AppLog.i(
        'Track saved id=${track.id} points=${track.points.length} '
        'distance=${track.distanceMeters.toStringAsFixed(1)}m',
      );
      _emitLoaded();
    } catch (error, stackTrace) {
      AppLog.e('Track save failed id=$sessionId', error, stackTrace);
      _saveError = 'Не удалось сохранить маршрут';
      _emitLoaded();
    }
  }

  void clearSaveError() {
    if (_saveError == null) {
      return;
    }
    _saveError = null;
    _emitLoaded();
  }

  void clearSessionInterruptedMessage() {
    if (_sessionInterruptedMessage == null) {
      return;
    }
    _sessionInterruptedMessage = null;
    _emitLoaded();
  }

  bool get canPlaceMarker =>
      _trackingStatus == TrackingStatus.tracking ||
      _trackingStatus == TrackingStatus.pause;

  String? addMarker({
    required double latitude,
    required double longitude,
    required String title,
    required String description,
  }) {
    if (!canPlaceMarker) {
      return 'Маркер можно поставить только во время записи';
    }
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();
    if (trimmedTitle.isEmpty || trimmedDescription.isEmpty) {
      return 'Нужны название и описание';
    }
    unawaited(
      _trackRecordingService.addMarker(
        Marker(
          id: _uuid.v4(),
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          title: trimmedTitle,
          description: trimmedDescription,
        ),
      ),
    );
    AppLog.i('Marker added lat=$latitude lon=$longitude title=$trimmedTitle');
    return null;
  }

  LatLng? currentMarkerPosition() {
    final latest = _trackRecordingService.currentSnapshot.latestPosition;
    if (latest != null) {
      return LatLng(latest.latitude, latest.longitude);
    }
    final last = _trackRecordingService.currentSnapshot.lastAcceptedPoint;
    if (last != null) {
      return LatLng(last.latitude, last.longitude);
    }
    return _userPosition?.currentPosition;
  }

  Future<void> deleteTrack() async {
    await _trackRecordingService.reset(discardDraft: true);
    _resetRecordingUiState();
    _emitLoaded();
  }

  void openAppSettings() async {
    await _geolocationService.openAppSettings();
    _emitLoaded();
  }

  void _resetRecordingUiState() {
    _recordingPoints = const [];
    _trackMarkers = const [];
    _distanceMeters = 0;
    _elapsedTime = Duration.zero;
    _currentSpeedKmh = null;
    _averageSpeedKmh = 0;
    _trackingStatus = TrackingStatus.rest;
    _cameraFollowEnabled = true;
    _saveError = null;
    _stopElapsedTimer();
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_trackingStatus != TrackingStatus.tracking) {
        return;
      }
      _elapsedTime = _trackRecordingService.currentSnapshot.elapsedTime;
      final averageMetersPerSecond = TrackCalculations.averageSpeedMps(
        _distanceMeters,
        _elapsedTime,
      );
      _averageSpeedKmh = TrackFormatters.metersPerSecondToKilometersPerHour(averageMetersPerSecond);
      _emitLoaded();
    });
  }

  void _stopElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  void _followUserPosition({bool animated = false}) {
    final position = _userPosition?.currentPosition;
    if (position == null) {
      return;
    }
    _currentMapCenter = position;
    moveMapCamera(_mapController, position, _currentZoom, animated: animated);
  }

  void _emitLoaded({double? initialZoom}) {
    if (initialZoom != null) {
      _currentZoom = initialZoom;
    }

    emit(
      MainState.loaded(
        trackingStatus: _trackingStatus,
        userPosition: _userPosition,
        initialMapCenter: _currentMapCenter,
        initialMapZoom: _currentZoom,
        recordingPoints: _recordingPoints,
        distanceMeters: _distanceMeters,
        elapsedTime: _elapsedTime,
        currentSpeedKmh: _currentSpeedKmh,
        averageSpeedKmh: _averageSpeedKmh,
        showRecenterButton:
            locateButtonKind(
              trackingStatus: _trackingStatus,
              cameraLockedToUser: _cameraFollowEnabled,
              hasUserPosition: _userPosition != null,
            ) !=
            LocateButtonKind.hidden,
        trackMarkers: _trackMarkers,
        saveError: _saveError,
        sessionInterruptedMessage: _sessionInterruptedMessage,
      ),
    );
  }

  @override
  Future<void> close() {
    _recordingSubscription?.cancel();
    _stopElapsedTimer();
    return super.close();
  }
}
