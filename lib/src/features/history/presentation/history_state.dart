import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geotracker/src/domain/track.dart';

part 'history_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class HistoryState with _$HistoryState {
  const factory HistoryState.initial() = _Initial;

  const factory HistoryState.loading() = _Loading;

  const factory HistoryState.loaded({
    required List<Track> tracks,
  }) = _Loaded;

  const factory HistoryState.error({required Object error}) = _Error;
}
