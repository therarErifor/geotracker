import 'package:flutter_bloc/flutter_bloc.dart';

import 'main_state.dart';

class MainCubit extends Cubit<MainState> {

  

  MainCubit() : super(MainStateInit()) {
    init();
  }

  void init() {
    emit(MainStateLoaded()); 
  }

  void startTracking() {
    emit(MainStateStart());
  }

  void pauseTracking() {
    emit(MainStatePause());
  }

  void finishTracking() {
    emit(MainStateFinish());
  }
  
  void saveTrack() {}

  void deleteTrack() {}
}