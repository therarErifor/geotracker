import 'package:geolocator/geolocator.dart';
import 'package:geotracker/src/entities/geo_position.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

@singleton
class GeolocationService {
  Stream<GeoPosition> getPositionStream() {
    return Geolocator.getPositionStream().map((p) => GeoPosition(
        longitude: p.longitude,
        latitude: p.latitude,
        timestamp: p.timestamp,
        speed: p.speed));
  }

  Future<LatLng?> getCurrentPositionAsync() async {
    bool hasPermissions = await _requestPermissionsAndEnableServiceAsync();
    if (!hasPermissions) {      
      return null;
    }

    var position = await Geolocator.getCurrentPosition();
    
    var currentPosition = LatLng(position.latitude, position.longitude);
    return currentPosition;
  }

  Future<LatLng> getLastKnownPositionAsync() async {
    bool hasPermissions = await _requestPermissionsAndEnableServiceAsync();
    if (!hasPermissions) {      
      return const LatLng(55.755864, 37.617698);
    }

    var position = await Geolocator.getLastKnownPosition();
    
    if (position == null) {
      return const LatLng(55.755864, 37.617698);
    }

    var lastPosition = LatLng(position.latitude, position.longitude);
    return lastPosition;
  }

  Future<bool> hasPermissionsAsync() async {
    var permissionStatus = await Geolocator.checkPermission();
    return permissionStatus == LocationPermission.whileInUse ||
        permissionStatus == LocationPermission.always;
  }

  Future<bool> requestPermissionsAsync() async {
    var permissionStatus = await Geolocator.requestPermission();
    return permissionStatus == LocationPermission.whileInUse ||
        permissionStatus == LocationPermission.always;
  }

  Future<bool> _requestPermissionsAndEnableServiceAsync() async {
    try {
      var isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        return false;
      }

      var permissionStatus = await Geolocator.checkPermission();
      if (permissionStatus == LocationPermission.deniedForever) {
        return false;
      }

      if (permissionStatus == LocationPermission.whileInUse ||
          permissionStatus == LocationPermission.always) {
        return true;
      }

      permissionStatus = await Geolocator.requestPermission();
      return permissionStatus == LocationPermission.whileInUse ||
          permissionStatus == LocationPermission.always;
    } catch (error, stack) {
      return false;
    }
  }
}
