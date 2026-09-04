import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geotracker/src/data/repositories/track_repository.dart';
import 'package:injectable/injectable.dart';

import 'history_state.dart';

@Injectable()
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._trackRepository) : super(const HistoryState.initial()) {
    load();
  }

  final TrackRepository _trackRepository;

  Future<void> load() async {
    emit(const HistoryState.loading());
    try {
      final tracks = await _trackRepository.getSummaries();
      emit(HistoryState.loaded(tracks: tracks));
    } catch (error) {
      emit(HistoryState.error(error: error));
    }
  }

  Future<void> rename(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    try {
      await _trackRepository.rename(id, trimmed);
      await load();
    } catch (error) {
      emit(HistoryState.error(error: error));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _trackRepository.delete(id);
      await load();
    } catch (error) {
      emit(HistoryState.error(error: error));
    }
  }
}
