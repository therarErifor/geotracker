import 'package:drift/drift.dart';
import 'package:geotracker/src/data/local/app_database.dart';
import 'package:geotracker/src/data/mappers/track_mapper.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class LocalTrackDataSource {
  LocalTrackDataSource(this._db, this._mapper);

  final AppDatabase _db;
  final TrackMapper _mapper;

  Future<void> insertTrack(Track track) async {
    await _db.transaction(() async {
      await _db.into(_db.tracks).insert(_mapper.trackToCompanion(track));
      final companions = _mapper.pointsToCompanions(track.id, track.points);
      for (final companion in companions) {
        await _db.into(_db.trackPoints).insert(companion);
      }
    });
  }

  Future<List<Track>> getTrackSummaries() async {
    final rows = await (_db.select(_db.tracks)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    return rows.map((row) => _mapper.trackFromRow(row)).toList();
  }

  Future<Track?> getTrackById(String id) async {
    final row = await (_db.select(_db.tracks)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }

    final pointRows = await (_db.select(_db.trackPoints)
          ..where((p) => p.trackId.equals(id))
          ..orderBy([(p) => OrderingTerm.asc(p.orderIndex)]))
        .get();

    return _mapper.trackFromRow(
      row,
      points: pointRows.map(_mapper.pointFromRow).toList(),
    );
  }

  Future<void> renameTrack(String id, String name) async {
    await (_db.update(_db.tracks)..where((t) => t.id.equals(id))).write(
      TracksCompanion(name: Value(name)),
    );
  }

  Future<void> deleteTrack(String id) async {
    await (_db.delete(_db.tracks)..where((t) => t.id.equals(id))).go();
  }
}
