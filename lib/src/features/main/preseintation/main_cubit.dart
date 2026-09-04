import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geotracker/src/data/repositories/track_repository.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_calculations.dart';
import 'package:geotracker/src/domain/track_point.dart';
import 'package:geotracker/src/entities/error_type.dart';
import 'package:geotracker/src/entities/tracking_status.dart';
import 'package:geotracker/src/entities/user_position.dart';
import 'package:geotracker/src/services/geolocation_service.dart';
import 'package:geotracker/src/services/track_recording_service.dart';
import 'package:geotracker/src/ui/formatters/track_formatters.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

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
  double _distanceMeters = 0;
  Duration _elapsedTime = Duration.zero;
  double? _currentSpeedKmh;
  double _averageSpeedKmh = 0;
  bool _cameraFollowEnabled = true;
  String? _saveError;
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
        emit(MainState.error(error: result.error!));
      }
      var position = result.data!;
      _currentMapCenter = LatLng(position.latitude, position.longitude);
      _userPosition = UserPosition(
        currentPosition: _currentMapCenter,
        heading: position.heading,
      );
      _emitLoaded();
    } catch (e) {
      _currentMapCenter = LatLng(58.021688, 56.227984);
      _emitLoaded(initialZoom: _currentZoom - 14);
    }
  }

  void _onRecordingSnapshot(RecordingSnapshot snapshot) {
    _recordingPoints = snapshot.points;
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
          ? TrackFormatters.mpsToKmh(latest.speed!)
          : null;
    }

    final avgMps = TrackCalculations.averageSpeedMps(
      _distanceMeters,
      _elapsedTime,
    );
    _averageSpeedKmh = TrackFormatters.mpsToKmh(avgMps);

    if (_trackingStatus == TrackingStatus.tracking && _cameraFollowEnabled) {
      _followUserPosition();
    }

    _emitLoaded();
  }

  void onMapCameraChanged(MapCamera camera, bool hasGesture) {
    _currentMapCenter = camera.center;
    _currentZoom = camera.zoom;

    if (hasGesture && _trackingStatus == TrackingStatus.tracking) {
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
        _mapController.move(_userPosition!.currentPosition, _currentZoom);
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
    _followUserPosition();
    _emitLoaded();
  }

  void zoomIn() {
    _currentZoom = _currentZoom + 0.6;
    _mapController.move(_currentMapCenter, _currentZoom);
  }

  void zoomOut() {
    _currentZoom = _currentZoom - 0.6;
    _mapController.move(_currentMapCenter, _currentZoom);
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

  void pauseTracking() {
    _trackRecordingService.pause();
    _trackingStatus = TrackingStatus.pause;
    _elapsedTime = _trackRecordingService.currentSnapshot.elapsedTime;
    _stopElapsedTimer();
    _emitLoaded();
  }

  void finishTracking() {
    _trackRecordingService.finish();
    _trackingStatus = TrackingStatus.finish;
    _elapsedTime = _trackRecordingService.currentSnapshot.elapsedTime;
    _stopElapsedTimer();
    _emitLoaded();
  }

  Future<void> saveTrack() async {
    final snapshot = _trackRecordingService.currentSnapshot;
    final startedAt = snapshot.startedAt;
    if (startedAt == null || snapshot.points.isEmpty) {
      _saveError = 'Недостаточно данных для сохранения маршрута';
      _emitLoaded();
      return;
    }

    final duration = snapshot.elapsedTime;
    final distance = TrackCalculations.totalDistanceMeters(snapshot.points);
    final track = Track(
      id: _uuid.v4(),
      name: TrackFormatters.defaultTrackName(startedAt),
      startedAt: startedAt,
      finishedAt: snapshot.finishedAt ?? DateTime.now(),
      duration: duration,
      movingDuration: duration,
      stoppedDuration: Duration.zero,
      distanceMeters: distance,
      averageSpeedMps: TrackCalculations.averageSpeedMps(distance, duration),
      maxSpeedMps: TrackCalculations.maxSpeedMps(snapshot.points),
      elevationGainMeters: TrackCalculations.elevationGainMeters(
        snapshot.points,
      ),
      points: List.unmodifiable(snapshot.points),
    );

    try {
      await _trackRepository.save(track);
      _trackRecordingService.reset();
      _resetRecordingUiState();
      _emitLoaded();
    } catch (error) {
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

  void deleteTrack() {
    _trackRecordingService.reset();
    _resetRecordingUiState();
    _emitLoaded();
  }

  void openAppSettings() async {
    await _geolocationService.openAppSettings();
    _emitLoaded();
  }

  void _resetRecordingUiState() {
    _recordingPoints = const [];
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
      final avgMps = TrackCalculations.averageSpeedMps(
        _distanceMeters,
        _elapsedTime,
      );
      _averageSpeedKmh = TrackFormatters.mpsToKmh(avgMps);
      _emitLoaded();
    });
  }

  void _stopElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  void _followUserPosition() {
    final position = _userPosition?.currentPosition;
    if (position == null) {
      return;
    }
    _currentMapCenter = position;
    _mapController.move(position, _currentZoom);
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
            _trackingStatus == TrackingStatus.tracking &&
            !_cameraFollowEnabled,
        saveError: _saveError,
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
