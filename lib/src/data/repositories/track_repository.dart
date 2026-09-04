import 'package:geotracker/src/domain/track.dart';

abstract class TrackRepository {
  Future<void> save(Track track);

  /// Tracks without points, newest first.
  Future<List<Track>> getSummaries();

  Future<Track?> getById(String id);

  Future<void> rename(String id, String name);

  Future<void> delete(String id);
}
