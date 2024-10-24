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
  late LatLng _currentMapCenter;
  late LatLng _currentUserPosition;
  late MapOptions _mapOptions;
  List<LatLng> trackPoints = [];

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
      _checkLocationPermissionAsync();
      final currentPosition = await _geolocationService.getCurrentPositionAsync();
      _currentMapCenter = currentPosition ?? await _geolocationService.getLastKnownPositionAsync();
      _currentUserPosition = _currentMapCenter;
      _mapOptions = MapOptions(
        onPositionChanged: _onPositionChanged,
        initialZoom: 16,
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
    _animatedMapController.animateTo(dest: camera.center);
  }

  void findMe() async =>
      _animatedMapController.animateTo(dest: _currentUserPosition);

  void zoomIn() async => _animatedMapController.animatedZoomIn();

  void zoomOut() async => _animatedMapController.animatedZoomOut();

  void startTracking() {
    _positionStreamSubscription = _geolocationService.getPositionStream().listen(_onPositionReseived);

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

  Future<void> _checkLocationPermissionAsync() async {
    final hasLocationPermission =
        await _geolocationService.hasPermissionsAsync();
    if (!hasLocationPermission) {
      _geolocationService.requestPermissionsAsync();
    }
  }

  void _onPositionReseived(GeoPosition position) {
    trackPoints.add(LatLng(position.latitude, position.longitude));
    emit(MainState.loaded(trackingStatus: _trackingStatus, options: _mapOptions, animatedMapController: _animatedMapController, points: trackPoints));
  }

  Future<void> _onGeolocationStateChanged(bool isLocationIsEnabled) async {
    if (!isLocationIsEnabled) {
      emit(MainState.geolocationIsNotWork());
    }
    emit(MainState.init());
  }
}
