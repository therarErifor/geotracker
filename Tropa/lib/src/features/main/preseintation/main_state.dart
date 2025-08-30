import 'package:flutter_map/flutter_map.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geotracker/src/entities/error_type.dart';

import '../../../entities/tracking_status.dart';
import '../../../entities/user_position.dart';

part 'main_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class MainState with _$MainState {
  const factory MainState.init() = _Init;

  const factory MainState.loaded({
    required MapOptions options,
    required MapController mapController,
    required TrackingStatus trackingStatus,
    required UserPosition? userPosition,
  }) = _Loaded;

  const factory MainState.error({required Object error}) = _Error;
}
