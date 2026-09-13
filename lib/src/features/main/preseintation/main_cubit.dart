import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' hide Marker;
import 'package:geotracker/src/core/app_log.dart';
import 'package:geotracker/src/data/repositories/track_repository.dart';
import 'package:geotracker/src/domain/course.dart';
import 'package:geotracker/src/domain/marker.dart';
import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/stop_detection.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_calculations.dart';
import 'package:geotracker/src/domain/track_point.dart';
import 'package:geotracker/src/entities/error_type.dart';
import 'package:geotracker/src/entities/geo_fix.dart';
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

enum _CameraFollowStyle { instant, smooth, locate }

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

  List<PauseInterval> get pauseIntervals => _pauseIntervals;

  late final LatLng _mapInitialCenter;
  late final double _mapInitialZoom;

  LatLng get mapInitialCenter => _mapInitialCenter;
  double get mapInitialZoom => _mapInitialZoom;

  double _currentZoom = 16;
  late LatLng _currentMapCenter;
  UserPosition? _userPosition;
  TrackingStatus _trackingStatus = TrackingStatus.rest;
  List<TrackPoint> _recordingPoints = const [];
  List<PauseInterval> _pauseIntervals = const [];
  List<Marker> _trackMarkers = const [];
  double _distanceMeters = 0;
  Duration _elapsedTime = Duration.zero;
  double? _currentSpeedKmh;
  double _averageSpeedKmh = 0;
  bool _cameraFollowEnabled = true;
  bool _locateRecenterAnimating = false;
  String? _saveError;
  String? _sessionInterruptedMessage;
  StreamSubscription<RecordingSnapshot>? _recordingSubscription;
  StreamSubscription<GeoFix>? _restPositionSubscription;
  Timer? _elapsedTimer;
  Timer? _locateRecenterAnimationTimer;

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
      _mapInitialCenter = _currentMapCenter;
      _mapInitialZoom = _currentZoom;
      _applyGpsFix(
        latitude: position.latitude,
        longitude: position.longitude,
        gpsHeading: position.courseDegrees,
        speedMps: position.speedMps,
        minDistanceMeters: Course.restMinDistanceMeters,
      );
      await _restoreSessionIfNeeded();
      AppLog.i('MainCubit.init ok lat=${position.latitude} lon=${position.longitude}');
      if (_trackingStatus == TrackingStatus.rest) {
        _startRestPositionWatch();
      }
      _emitLoaded();
    } catch (e, stackTrace) {
      AppLog.e('MainCubit.init fallback map center', e, stackTrace);
      _currentMapCenter = LatLng(58.021688, 56.227984);
      _currentZoom = _currentZoom - 14;
      _mapInitialCenter = _currentMapCenter;
      _mapInitialZoom = _currentZoom;
      await _restoreSessionIfNeeded();
      if (_trackingStatus == TrackingStatus.rest) {
        _startRestPositionWatch();
      }
      _emitLoaded();
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
    _pauseIntervals = snapshot.pauseIntervals;
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
      final previousPoint = snapshot.points.length >= 2
          ? snapshot.points[snapshot.points.length - 2]
          : null;
      _userPosition = UserPosition(
        currentPosition: LatLng(latest.latitude, latest.longitude),
        heading: Course.resolveCourseDegrees(
          gpsHeading: snapshot.courseDegrees,
          speedMps: latest.speed,
          from: previousPoint,
          to: latest,
          minDistanceMeters: Course.recordingMinDistanceMeters,
        ),
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
    _pauseIntervals = snapshot.pauseIntervals;
    _trackMarkers = snapshot.markers;
    _elapsedTime = snapshot.elapsedTime;
    _distanceMeters = TrackCalculations.totalDistanceMeters(snapshot.points);

    final latest = snapshot.latestPosition;
    if (latest != null) {
      _applyGpsFix(
        latitude: latest.latitude,
        longitude: latest.longitude,
        gpsHeading: snapshot.courseDegrees,
        speedMps: latest.speed,
        minDistanceMeters: Course.recordingMinDistanceMeters,
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

    if (_cameraFollowEnabled && _isActiveRecordingFollow()) {
      _followUserPosition(style: _CameraFollowStyle.smooth);
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

        _applyGpsFix(
          latitude: position.latitude,
          longitude: position.longitude,
          gpsHeading: position.courseDegrees,
          speedMps: position.speedMps,
          minDistanceMeters: _trackingStatus == TrackingStatus.rest
              ? Course.restMinDistanceMeters
              : Course.recordingMinDistanceMeters,
        );
        _cameraFollowEnabled = true;
        _beginLocateRecenterAnimation();
        _followUserPosition(style: _CameraFollowStyle.locate);
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
    _beginLocateRecenterAnimation();
    _followUserPosition(style: _CameraFollowStyle.locate);
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
    await _stopRestPositionWatch();
    try {
      if (_trackingStatus == TrackingStatus.pause) {
        await _trackRecordingService.resume();
      } else {
        await _trackRecordingService.start();
      }
    } catch (error, stackTrace) {
      AppLog.e('MainCubit.tracking failed', error, stackTrace);
      if (_trackingStatus == TrackingStatus.rest) {
        _startRestPositionWatch();
      }
      _emitLoaded();
      return;
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
      pauseIntervals: List.unmodifiable(snapshot.pauseIntervals),
    );

    try {
      await _trackRepository.finalizeTrack(track);
      await _trackRecordingService.reset();
      _resetRecordingUiState();
      _startRestPositionWatch();
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
    _startRestPositionWatch();
    _emitLoaded();
  }

  void openAppSettings() async {
    await _geolocationService.openAppSettings();
    _emitLoaded();
  }

  void _resetRecordingUiState() {
    _recordingPoints = const [];
    _pauseIntervals = const [];
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

  void _startRestPositionWatch() {
    if (_trackingStatus != TrackingStatus.rest ||
        _restPositionSubscription != null) {
      return;
    }
    _restPositionSubscription = _geolocationService.watchPosition().listen(
      _onRestPosition,
      onError: (Object error, StackTrace stackTrace) {
        AppLog.e('Rest GPS stream error', error, stackTrace);
      },
    );
  }

  Future<void> _stopRestPositionWatch() async {
    await _restPositionSubscription?.cancel();
    _restPositionSubscription = null;
  }

  void _onRestPosition(GeoFix position) {
    if (_trackingStatus != TrackingStatus.rest) {
      return;
    }
    _applyGpsFix(
      latitude: position.latitude,
      longitude: position.longitude,
      gpsHeading: position.courseDegrees,
      speedMps: position.speedMps,
      minDistanceMeters: Course.restMinDistanceMeters,
    );
    if (_cameraFollowEnabled) {
      _followUserPosition(style: _CameraFollowStyle.smooth);
    }
    _emitLoaded();
  }

  void _applyGpsFix({
    required double latitude,
    required double longitude,
    required double minDistanceMeters,
    double? gpsHeading,
    double? speedMps,
  }) {
    final next = LatLng(latitude, longitude);
    final previous = _userPosition?.currentPosition;
    final from = previous == null
        ? null
        : TrackPoint(
            latitude: previous.latitude,
            longitude: previous.longitude,
            timestamp: DateTime.fromMillisecondsSinceEpoch(0),
          );
    final to = TrackPoint(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
    );
    _userPosition = UserPosition(
      currentPosition: next,
      heading: Course.resolveCourseDegrees(
        gpsHeading: gpsHeading,
        speedMps: speedMps,
        from: from,
        to: to,
        minDistanceMeters: minDistanceMeters,
        previousCourseDegrees: _userPosition?.heading,
      ),
      speed: speedMps,
    );
  }

  bool _isActiveRecordingFollow() {
    return _trackingStatus == TrackingStatus.tracking ||
        _trackingStatus == TrackingStatus.pause;
  }

  void _beginLocateRecenterAnimation() {
    _locateRecenterAnimating = true;
    _locateRecenterAnimationTimer?.cancel();
    _locateRecenterAnimationTimer = Timer(mapCameraAnimationDuration, () {
      _locateRecenterAnimating = false;
    });
  }

  void _followUserPosition({_CameraFollowStyle style = _CameraFollowStyle.instant}) {
    final position = _userPosition?.currentPosition;
    if (position == null) {
      return;
    }
    if (style == _CameraFollowStyle.instant &&
        isMapCameraAnimating(_mapController)) {
      return;
    }
    if (style == _CameraFollowStyle.smooth && _locateRecenterAnimating) {
      return;
    }

    switch (style) {
      case _CameraFollowStyle.instant:
        moveMapCamera(_mapController, position, _currentZoom, animated: false);
      case _CameraFollowStyle.smooth:
        moveMapCamera(
          _mapController,
          position,
          _currentZoom,
          animated: true,
          duration: _trackingStatus == TrackingStatus.rest
              ? mapRestFollowAnimationDuration
              : mapGpsFollowAnimationDuration,
          curve: mapGpsFollowAnimationCurve,
        );
      case _CameraFollowStyle.locate:
        moveMapCamera(_mapController, position, _currentZoom, animated: true);
    }
  }

  void _emitLoaded() {
    emit(
      MainState.loaded(
        trackingStatus: _trackingStatus,
        userPosition: _userPosition,
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
  Future<void> close() async {
    await _recordingSubscription?.cancel();
    await _stopRestPositionWatch();
    _stopElapsedTimer();
    _locateRecenterAnimationTimer?.cancel();
    return super.close();
  }
}
