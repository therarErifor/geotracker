import 'package:geolocator/geolocator.dart';
import 'package:geotracker/src/entities/error_type.dart';
import 'package:injectable/injectable.dart';

import '../entities/request_result.dart';

@singleton
class GeolocationService {
  Future<RequestResult<Position?>> getCurrentPositionAsync() async {
    var result = await _requestPermissionsAndEnableServiceAsync();
    if (result.error != null) {
      return RequestResult.fromError(result.error!);
    }
    var position = await Geolocator.getLastKnownPosition();
    position ??= await Geolocator.getCurrentPosition();

    return RequestResult.fromData(position);
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

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<RequestResult<bool>> _requestPermissionsAndEnableServiceAsync() async {
    try {
      var permissionStatus = await Geolocator.checkPermission();
      if (permissionStatus == LocationPermission.denied ||
          permissionStatus == LocationPermission.deniedForever) {
        return RequestResult(false, ErrorType.permissionDenied);
      }

      var isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        return RequestResult.fromData(false);
      }

      if (permissionStatus == LocationPermission.whileInUse ||
          permissionStatus == LocationPermission.always) {
        return RequestResult.fromData(true);
      }

      permissionStatus = await Geolocator.requestPermission();
      return RequestResult.fromData(
        permissionStatus == LocationPermission.whileInUse ||
            permissionStatus == LocationPermission.always,
      );
    } catch (error, stack) {
      return RequestResult(null, error);
    }
  }
}
