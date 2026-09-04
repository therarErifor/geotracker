import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geotracker/src/data/repositories/track_repository.dart';
import 'package:injectable/injectable.dart';

import 'details_state.dart';

@Injectable()
class DetailsCubit extends Cubit<DetailsState> {
  DetailsCubit(this._trackRepository) : super(const DetailsState.initial());

  final TrackRepository _trackRepository;

  Future<void> load(String trackId) async {
    emit(const DetailsState.loading());
    try {
      final track = await _trackRepository.getById(trackId);
      if (track == null) {
        emit(const DetailsState.error(error: 'Маршрут не найден'));
        return;
      }
      emit(DetailsState.loaded(track: track));
    } catch (error) {
      emit(DetailsState.error(error: error));
    }
  }
}
