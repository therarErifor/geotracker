import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import 'main_state.dart';

@Injectable()
class MainCubit extends Cubit<MainState> {

  

  MainCubit() : super(const MainState.init()) {
    init();
  }

  void init() {
    emit(const MainState.loaded(
      options: MapOptions(
        initialCenter: LatLng(57.982799, 56.199450),
      )
    )); 
  }

  void startTracking() {
    // emit(MainStateStart());
  }

  void pauseTracking() {
    // emit(MainStatePause());
  }

  void finishTracking() {
    // emit(MainStateFinish());
  }
  
  void saveTrack() {}

  void deleteTrack() {}
}