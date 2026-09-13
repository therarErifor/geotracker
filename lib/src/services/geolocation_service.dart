import 'dart:io' show Platform;

import 'package:geolocator/geolocator.dart';
import 'package:geotracker/src/domain/course.dart';
import 'package:geotracker/src/entities/error_type.dart';
import 'package:geotracker/src/entities/geo_fix.dart';
import 'package:injectable/injectable.dart';

import '../entities/request_result.dart';

@singleton
class GeolocationService {
  static double? courseDegreesFrom(Position position) {
    if (!position.hasHeading || position.heading < 0) {
      return null;
    }
    if (position.hasHeadingAccuracy &&
        (position.headingAccuracy < 0 || position.headingAccuracy > 45)) {
      return null;
    }
    if (position.speed < Course.minSpeedMps) {
      return null;
    }
    return position.heading % 360;
  }

  static GeoFix toGeoFix(Position position) {
    return GeoFix(
      latitude: position.latitude,
      longitude: position.longitude,
      speedMps: position.speed >= 0 ? position.speed : null,
      courseDegrees: courseDegreesFrom(position),
    );
  }

  Future<RequestResult<GeoFix?>> getCurrentPositionAsync() async {
    var result = await _requestPermissionsAndEnableServiceAsync();
    if (result.error != null) {
      return RequestResult.fromError(result.error!);
    }
    var position = await Geolocator.getLastKnownPosition();
    position ??= await Geolocator.getCurrentPosition();

    return RequestResult.fromData(toGeoFix(position));
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

  Stream<GeoFix> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: _displayLocationSettings(),
    ).map(toGeoFix);
  }

  LocationSettings _displayLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 8,
        intervalDuration: const Duration(seconds: 2),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 8,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: false,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 8,
    );
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
