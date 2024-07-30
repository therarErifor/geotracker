import 'package:flutter_map/flutter_map.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class MainState with _$MainState {
  const factory MainState.init() = _Init;

  const factory MainState.loaded(
    {required MapOptions options}) = _Loaded;
  
  const factory MainState.tracking() = _Tracking;
  
  const factory MainState.finish() = _Finish;
  
  const factory MainState.error() = _Error; 
}