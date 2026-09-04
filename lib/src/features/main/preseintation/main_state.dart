import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geotracker/src/domain/track_point.dart';
import 'package:latlong2/latlong.dart';

import '../../../entities/tracking_status.dart';
import '../../../entities/user_position.dart';

part 'main_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class MainState with _$MainState {
  const factory MainState.init() = _Init;

  const factory MainState.loaded({
    required TrackingStatus trackingStatus,
    required UserPosition? userPosition,
    required LatLng initialMapCenter,
    @Default(16.0) double initialMapZoom,
    @Default(<TrackPoint>[]) List<TrackPoint> recordingPoints,
    @Default(0.0) double distanceMeters,
    @Default(Duration.zero) Duration elapsedTime,
    double? currentSpeedKmh,
    @Default(0.0) double averageSpeedKmh,
    @Default(false) bool showRecenterButton,
    String? saveError,
  }) = _Loaded;

  const factory MainState.error({required Object error}) = _Error;
}
