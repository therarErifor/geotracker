import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geotracker/src/domain/track.dart';

part 'details_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class DetailsState with _$DetailsState {
  const factory DetailsState.initial() = _Initial;

  const factory DetailsState.loading() = _Loading;

  const factory DetailsState.loaded({required Track track}) = _Loaded;

  const factory DetailsState.error({required Object error}) = _Error;
}
