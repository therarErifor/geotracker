import 'package:geotracker/src/data/datasources/local_track_datasource.dart';
import 'package:geotracker/src/data/repositories/track_repository.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TrackRepository)
class TrackRepositoryImpl implements TrackRepository {
  TrackRepositoryImpl(this._dataSource);

  final LocalTrackDataSource _dataSource;

  @override
  Future<void> save(Track track) => _dataSource.insertTrack(track);

  @override
  Future<List<Track>> getSummaries() => _dataSource.getTrackSummaries();

  @override
  Future<Track?> getById(String id) => _dataSource.getTrackById(id);

  @override
  Future<void> rename(String id, String name) =>
      _dataSource.renameTrack(id, name);

  @override
  Future<void> delete(String id) => _dataSource.deleteTrack(id);
}
