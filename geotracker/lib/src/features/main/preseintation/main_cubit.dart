import 'dart:async';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geotracker/src/entities/geo_position.dart';
import 'package:geotracker/src/services/geolocation_service.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import 'main_state.dart';

enum TrackingStatus { isNotTracking, isTracking, isPaused }

@Injectable()
class MainCubit extends Cubit<MainState> {
  final GeolocationService _geolocationService;
  final AnimatedMapController _animatedMapController;
  late TrackingStatus _trackingStatus;
  double _currentZoom = 16;
  late LatLng _currentMapCenter;
  late LatLng _currentUserPosition;
  late MapOptions _mapOptions;

  StreamSubscription<GeoPosition>? _positionStreamSubscription;

  MainCubit(GeolocationService geolocationService,
      @factoryParam AnimatedMapController mapController)
      : _geolocationService = geolocationService,
        _animatedMapController = mapController,
        super(const MainState.init()) {
    init();
  }

  void init() async {
    try {
      _trackingStatus = TrackingStatus.isNotTracking;

      final hasLocationPermission =
          await _geolocationService.hasPermissionsAsync();
      if (!hasLocationPermission) {
        _geolocationService.requestPermissionsAsync();
      }
      _currentMapCenter = await _geolocationService.getCurrentPositionAsync();
      _currentUserPosition = _currentMapCenter;
      _mapOptions = MapOptions(
        onPositionChanged: _onPositionChanged,
        initialZoom: _currentZoom,
        initialCenter: _currentMapCenter,
      );
      emit(MainState.loaded(
          trackingStatus: _trackingStatus,
          options: _mapOptions,
          animatedMapController: _animatedMapController));
    } catch (e, s) {
      emit(MainState.error());
    }
  }

  void _onPositionChanged(MapCamera camera, bool isThat) {
    _currentMapCenter = camera.center;
    _currentZoom = camera.zoom;
    _animatedMapController.mapController.move(camera.center, camera.zoom);
  }

  void findMe() async =>
      _animatedMapController.animateTo(dest: _currentUserPosition);

  void zoomIn() async => _animatedMapController.animatedZoomIn();

  void zoomOut() async => _animatedMapController.animatedZoomOut();

  void startTracking() {
    _trackingStatus = TrackingStatus.isTracking;
    emit(MainState.loaded(
        trackingStatus: _trackingStatus,
        options: _mapOptions,
        animatedMapController: _animatedMapController));
  }

  void pauseTracking() {
    _trackingStatus = TrackingStatus.isPaused;
    emit(MainState.loaded(
        trackingStatus: _trackingStatus,
        options: _mapOptions,
        animatedMapController: _animatedMapController));
  }

  void finishTracking() async {
    _trackingStatus = TrackingStatus.isNotTracking;
    emit(MainState.loaded(
        trackingStatus: _trackingStatus,
        options: _mapOptions,
        animatedMapController: _animatedMapController));
  }

  void saveTrack() {}

  void deleteTrack() {}
}
