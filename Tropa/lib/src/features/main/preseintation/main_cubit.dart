import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geotracker/src/entities/error_type.dart';
import 'package:geotracker/src/entities/user_position.dart';
import 'package:geotracker/src/services/geolocation_service.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../entities/tracking_status.dart';
import 'main_state.dart';

@Injectable()
class MainCubit extends Cubit<MainState> {
  final GeolocationService _geolocationService;
  final MapController _mapController = MapController();
  double _currentZoom = 16;
  late LatLng _currentMapCenter;
  UserPosition? _userPosition;

  MainCubit(GeolocationService geolocationService)
    : _geolocationService = geolocationService,
      super(const MainState.init()) {
    init();
  }

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
      emit(
        MainState.loaded(
          options: MapOptions(
            onPositionChanged: _onPositionChanged,
            initialZoom: _currentZoom,
            initialCenter: _currentMapCenter,
          ),
          mapController: _mapController,
          trackingStatus: TrackingStatus.rest,
          userPosition: _userPosition,
        ),
      );
    } catch (e) {
      _currentMapCenter = LatLng(58.021688, 56.227984);
      emit(
        MainState.loaded(
          options: MapOptions(
            onPositionChanged: _onPositionChanged,
            initialZoom: _currentZoom - 14,
            initialCenter: _currentMapCenter,
          ),
          mapController: _mapController,
          trackingStatus: TrackingStatus.rest,
          userPosition: _userPosition,
        ),
      );
    }
  }

  void _onPositionChanged(MapCamera camera, bool isThat) {
    _currentMapCenter = camera.center;
    _currentZoom = camera.zoom;
    _mapController.move(camera.center, camera.zoom);
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
      }
      emit(
        MainState.loaded(
          options: MapOptions(
            onPositionChanged: _onPositionChanged,
            initialZoom: _currentZoom,
            initialCenter: _currentMapCenter,
          ),
          mapController: _mapController,
          trackingStatus: TrackingStatus.tracking,
          userPosition: _userPosition,
        ),
      );
    } catch (e, s) {
      emit(
        MainState.loaded(
          options: MapOptions(
            onPositionChanged: _onPositionChanged,
            initialZoom: _currentZoom,
            initialCenter: _currentMapCenter,
          ),
          mapController: _mapController,
          trackingStatus: TrackingStatus.tracking,
          userPosition: _userPosition,
        ),
      );
    }
  }

  void zoomIn() {
    _currentZoom = _currentZoom + 0.6;
    _mapController.move(_currentMapCenter, _currentZoom);
  }

  void zoomOut() {
    _currentZoom = _currentZoom - 0.6;
    _mapController.move(_currentMapCenter, _currentZoom);
  }

  void tracking() {
    emit(
      MainState.loaded(
        options: MapOptions(
          onPositionChanged: _onPositionChanged,
          initialZoom: _currentZoom,
          initialCenter: _currentMapCenter,
        ),
        mapController: _mapController,
        trackingStatus: TrackingStatus.tracking,
        userPosition: _userPosition,
      ),
    );
  }

  void pauseTracking() {
    emit(
      MainState.loaded(
        options: MapOptions(
          onPositionChanged: _onPositionChanged,
          initialZoom: _currentZoom,
          initialCenter: _currentMapCenter,
        ),
        mapController: _mapController,
        trackingStatus: TrackingStatus.pause,
        userPosition: _userPosition,
      ),
    );
  }

  void finishTracking() {
    emit(
      MainState.loaded(
        options: MapOptions(
          onPositionChanged: _onPositionChanged,
          initialZoom: _currentZoom,
          initialCenter: _currentMapCenter,
        ),
        mapController: _mapController,
        trackingStatus: TrackingStatus.finish,
        userPosition: _userPosition,
      ),
    );
  }

  void saveTrack() {
    emit(
      MainState.loaded(
        options: MapOptions(
          onPositionChanged: _onPositionChanged,
          initialZoom: _currentZoom,
          initialCenter: _currentMapCenter,
        ),
        mapController: _mapController,
        trackingStatus: TrackingStatus.rest,
        userPosition: _userPosition,
      ),
    );
  }

  void deleteTrack() {
    emit(
      MainState.loaded(
        options: MapOptions(
          onPositionChanged: _onPositionChanged,
          initialZoom: _currentZoom,
          initialCenter: _currentMapCenter,
        ),
        mapController: _mapController,
        trackingStatus: TrackingStatus.rest,
        userPosition: _userPosition,
      ),
    );
  }

  void openAppSettings() async {
    await _geolocationService.openAppSettings();
    emit(
      MainState.loaded(
        options: MapOptions(
          onPositionChanged: _onPositionChanged,
          initialZoom: _currentZoom,
          initialCenter: _currentMapCenter,
        ),
        mapController: _mapController,
        trackingStatus: TrackingStatus.rest,
        userPosition: _userPosition,
      ),
    );
  }
}
