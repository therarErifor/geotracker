import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geotracker/src/domain/track.dart';

part 'replay_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class ReplayState with _$ReplayState {
  const factory ReplayState.initial() = _Initial;

  const factory ReplayState.loading() = _Loading;

  const factory ReplayState.loaded({
    required Track track,
    required Duration playbackTime,
    required double speed,
    required bool isPlaying,
    required bool showRecenterButton,
  }) = _Loaded;

  const factory ReplayState.error({required Object error}) = _Error;
}
