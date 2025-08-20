import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

@singleton
class GeolocationService {
  Future<LatLng> getCurrentPositionAsync() async {
    var hasPermissions = await _requestPermissionsAndEnableServiceAsync();
    if (!hasPermissions) {
      return const LatLng(55.755864, 37.617698);
    }

    var position = await Geolocator.getLastKnownPosition();
    if (position == null) {
      position = await Geolocator.getCurrentPosition();
    } else {
      Geolocator.getCurrentPosition();
    }

    var currentPosition = position != null ? LatLng(position.latitude, position.longitude) : const LatLng(55.755864, 37.617698);
    return currentPosition;
  }

  Future<bool> hasPermissionsAsync() async {
    var permissionStatus = await Geolocator.checkPermission();
    return permissionStatus == LocationPermission.whileInUse || permissionStatus == LocationPermission.always;
  }

  Future<bool> requestPermissionsAsync() async {
    var permissionStatus = await Geolocator.requestPermission();
    return permissionStatus == LocationPermission.whileInUse || permissionStatus == LocationPermission.always;
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

      if (permissionStatus == LocationPermission.whileInUse || permissionStatus == LocationPermission.always) {
        return true;
      }

      permissionStatus = await Geolocator.requestPermission();
      return permissionStatus == LocationPermission.whileInUse || permissionStatus == LocationPermission.always;
    } catch (error, stack) {
      return false;
    }
  }
}