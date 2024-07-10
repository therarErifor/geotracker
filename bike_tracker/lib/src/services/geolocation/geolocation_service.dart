import 'package:geolocator/geolocator.dart';

class GeolocationService extends Geolocator {

  Stream<Position>realTimeWorkLocationStream() {
    return Geolocator.getPositionStream();
  }

  Future<bool> getPermissionsAsync() async {
    final permissionStatus = await Geolocator.requestPermission();
    
    return permissionStatus == LocationPermission.whileInUse || 
    permissionStatus == LocationPermission.always;
  }

  Future<bool> checkPermissionAsync() async {
    final locationPermission = await Geolocator.checkPermission();
    
    return locationPermission == LocationPermission.whileInUse || 
      locationPermission == LocationPermission.always;
  }

  Future<bool> openLocationSettingsAsync() async {
    return Geolocator.openLocationSettings();
  }


}