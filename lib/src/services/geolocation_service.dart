import 'dart:io' show Platform;

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

  Future<bool> requestAlwaysPermission() async {
    var permissionStatus = await Geolocator.checkPermission();
    if (permissionStatus == LocationPermission.denied ||
        permissionStatus == LocationPermission.deniedForever) {
      permissionStatus = await Geolocator.requestPermission();
    }
    if (permissionStatus == LocationPermission.whileInUse) {
      permissionStatus = await Geolocator.requestPermission();
    }
    return permissionStatus == LocationPermission.whileInUse ||
        permissionStatus == LocationPermission.always;
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Stream<Position> watchPosition() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  Stream<Position> watchRecordingPosition() {
    return Geolocator.getPositionStream(
      locationSettings: _recordingLocationSettings(),
    );
  }

  LocationSettings _recordingLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Geotracker',
          notificationText: 'Идёт запись маршрута',
          notificationChannelName: 'Запись маршрута',
          notificationIcon: AndroidResource(
            name: 'ic_launcher',
            defType: 'mipmap',
          ),
          setOngoing: true,
          enableWakeLock: true,
        ),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
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
    } catch (error) {
      return RequestResult(null, error);
    }
  }
}
