import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'main_cubit.dart';

part 'main_state.freezed.dart';

@freezed
abstract class MainState with _$MainState {
  const factory MainState.init() = _Init;

  const factory MainState.loaded(
      {required TrackingStatus trackingStatus,
      required MapOptions options,
      required AnimatedMapController animatedMapController,
      List<LatLng>? points}) = _Loaded;

  const factory MainState.geolocationIsNotWork() = _GeolocationIsNotWork;

  const factory MainState.error() = _Error;
}
