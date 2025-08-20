import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geotracker/src/services/geolocation_service.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import 'main_state.dart';

@Injectable()
class MainCubit extends Cubit<MainState> {
  final GeolocationService _geolocationService;
  final MapController _mapController = MapController();
  double _currentZoom = 16;
  late LatLng _currentMapCenter;
  late LatLng _currentUserPosition;

  MainCubit(GeolocationService geolocationService)
      : _geolocationService = geolocationService,
        super(const MainState.init()) {
    init();
  }

  void init() async {
    try {
      final hasLocationPermission =
          await _geolocationService.hasPermissionsAsync();
      if (!hasLocationPermission) {
        _geolocationService.requestPermissionsAsync();
      }
      _currentMapCenter = await _geolocationService.getCurrentPositionAsync();
      _currentUserPosition = _currentMapCenter;
      emit(MainState.loaded(
          options: MapOptions(
            onPositionChanged: _onPositionChanged,
            initialZoom: _currentZoom,
            initialCenter: _currentMapCenter,
          ),
          mapController: _mapController));
    } catch (e, s) {
      emit(MainState.error());
    }
  }

  void _onPositionChanged(MapCamera camera, bool isThat) {
    _currentMapCenter = camera.center;
    _currentZoom = camera.zoom;
    _mapController.move(camera.center, camera.zoom);
  }

  void findMe() async {
    _currentUserPosition = await _geolocationService.getCurrentPositionAsync();
    _mapController.move(_currentUserPosition, _currentZoom);
  }

  void zoomIn() {
    _currentZoom = _currentZoom + 0.6;
    _mapController.move(
      _currentMapCenter,
      _currentZoom,
    );
  }

  void zoomOut() {
    _currentZoom = _currentZoom - 0.6;
    _mapController.move(_currentMapCenter, _currentZoom);
  }

  void startTracking() {
    
  }

  void pauseTracking() {
    // emit(MainStatePause());
  }

  void finishTracking() {
    // emit(MainStateFinish());
  }

  void saveTrack() {}

  void deleteTrack() {}
}
