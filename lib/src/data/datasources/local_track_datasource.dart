import 'package:drift/drift.dart';
import 'package:geotracker/src/data/local/app_database.dart';
import 'package:geotracker/src/data/mappers/track_mapper.dart';
import 'package:geotracker/src/domain/marker.dart';
import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/recording_draft.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_point.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class LocalTrackDataSource {
  LocalTrackDataSource(this._database, this._mapper);

  final AppDatabase _database;
  final TrackMapper _mapper;

  Future<void> insertTrack(Track track) async {
    await _database.transaction(() async {
      await _database.into(_database.tracks).insert(
            _mapper.trackToCompanion(track),
          );
      final companions = _mapper.pointsToCompanions(track.id, track.points);
      for (final companion in companions) {
        await _database.into(_database.trackPoints).insert(companion);
      }
      for (final companion in _mapper.stopsToCompanions(track.id, track.stops)) {
        await _database.into(_database.trackStops).insert(companion);
      }
      for (final companion
          in _mapper.markersToCompanions(track.id, track.markers)) {
        await _database.into(_database.trackMarkers).insert(companion);
      }
    });
  }

  Future<void> createDraft({
    required String id,
    required String name,
    required DateTime startedAt,
    required String recordingStatus,
  }) async {
    await _database.transaction(() async {
      final orphans = await (_database.select(_database.tracks)
            ..where((t) => t.finishedAt.isNull()))
          .get();
      for (final orphan in orphans) {
        await (_database.delete(_database.tracks)..where((t) => t.id.equals(orphan.id)))
            .go();
      }

      await _database.into(_database.tracks).insert(
            TracksCompanion.insert(
              id: id,
              name: name,
              startedAt: startedAt,
              finishedAt: const Value(null),
              recordingStatus: Value(recordingStatus),
              pauseIntervalsJson: Value(
                _mapper.encodePauseMeta(
                  intervals: const [],
                  totalPausedDuration: Duration.zero,
                ),
              ),
            ),
          );
    });
  }

  Future<void> updateDraftMeta({
    required String id,
    required String recordingStatus,
    required List<PauseInterval> pauseIntervals,
    required Duration totalPausedDuration,
    DateTime? openPauseStartedAt,
    double? distanceMeters,
    int? durationMs,
  }) async {
    await (_database.update(_database.tracks)
          ..where((t) => t.id.equals(id)))
        .write(
      TracksCompanion(
        recordingStatus: Value(recordingStatus),
        pauseIntervalsJson: Value(
          _mapper.encodePauseMeta(
            intervals: pauseIntervals,
            totalPausedDuration: totalPausedDuration,
            openPauseStartedAt: openPauseStartedAt,
          ),
        ),
        distanceMeters: distanceMeters != null
            ? Value(distanceMeters)
            : const Value.absent(),
        durationMs:
            durationMs != null ? Value(durationMs) : const Value.absent(),
      ),
    );
  }

  Future<void> appendPoints({
    required String trackId,
    required List<TrackPoint> points,
    required int startOrderIndex,
  }) async {
    if (points.isEmpty) {
      return;
    }
    final companions = _mapper.pointsToCompanions(
      trackId,
      points,
      startOrderIndex: startOrderIndex,
    );
    await _database.batch((batch) {
      batch.insertAll(_database.trackPoints, companions);
    });
  }

  Future<void> replaceMarkers({
    required String trackId,
    required List<Marker> markers,
  }) async {
    await _database.transaction(() async {
      await (_database.delete(_database.trackMarkers)
            ..where((m) => m.trackId.equals(trackId)))
          .go();
      for (final companion
          in _mapper.markersToCompanions(trackId, markers)) {
        await _database.into(_database.trackMarkers).insert(companion);
      }
    });
  }

  Future<RecordingDraft?> getActiveDraft() async {
    final row = await (_database.select(_database.tracks)
          ..where((t) => t.finishedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }

    final status = row.recordingStatus;
    if (status == null || status.isEmpty) {
      return null;
    }

    final pointRows = await (_database.select(_database.trackPoints)
          ..where((p) => p.trackId.equals(row.id))
          ..orderBy([(p) => OrderingTerm.asc(p.orderIndex)]))
        .get();
    final markerRows = await (_database.select(_database.trackMarkers)
          ..where((m) => m.trackId.equals(row.id))
          ..orderBy([(m) => OrderingTerm.asc(m.timestamp)]))
        .get();
    final pauseMeta = _mapper.decodePauseMeta(row.pauseIntervalsJson);

    return RecordingDraft(
      track: _mapper.trackFromRow(
        row,
        points: pointRows.map(_mapper.pointFromRow).toList(),
        markers: markerRows.map(_mapper.markerFromRow).toList(),
      ),
      recordingStatus: status,
      pauseIntervals: pauseMeta.intervals,
      totalPausedDuration: pauseMeta.totalPausedDuration,
      openPauseStartedAt: pauseMeta.openPauseStartedAt,
    );
  }

  Future<void> finalizeTrack(Track track) async {
    await _database.transaction(() async {
      await (_database.update(_database.tracks)..where((t) => t.id.equals(track.id))).write(
            TracksCompanion(
              name: Value(track.name),
              finishedAt: Value(track.finishedAt),
              durationMs: Value(track.duration.inMilliseconds),
              movingDurationMs: Value(track.movingDuration.inMilliseconds),
              stoppedDurationMs: Value(track.stoppedDuration.inMilliseconds),
              distanceMeters: Value(track.distanceMeters),
              averageSpeedMps: Value(track.averageSpeedMps),
              maxSpeedMps: Value(track.maxSpeedMps),
              elevationGainMeters: Value(track.elevationGainMeters),
              recordingStatus: const Value(null),
              pauseIntervalsJson: const Value(null),
            ),
          );

      await (_database.delete(_database.trackStops)
            ..where((s) => s.trackId.equals(track.id)))
          .go();
      for (final companion
          in _mapper.stopsToCompanions(track.id, track.stops)) {
        await _database.into(_database.trackStops).insert(companion);
      }

      await (_database.delete(_database.trackMarkers)
            ..where((m) => m.trackId.equals(track.id)))
          .go();
      for (final companion
          in _mapper.markersToCompanions(track.id, track.markers)) {
        await _database.into(_database.trackMarkers).insert(companion);
      }

      await (_database.delete(_database.trackPoints)
            ..where((p) => p.trackId.equals(track.id)))
          .go();
      for (final companion
          in _mapper.pointsToCompanions(track.id, track.points)) {
        await _database.into(_database.trackPoints).insert(companion);
      }
    });
  }

  Future<List<Track>> getTrackSummaries() async {
    final rows = await (_database.select(_database.tracks)
          ..where((t) => t.finishedAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    return rows.map((row) => _mapper.trackFromRow(row)).toList();
  }

  Future<Track?> getTrackById(String id) async {
    final row = await (_database.select(_database.tracks)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }

    final pointRows = await (_database.select(_database.trackPoints)
          ..where((p) => p.trackId.equals(id))
          ..orderBy([(p) => OrderingTerm.asc(p.orderIndex)]))
        .get();
    final stopRows = await (_database.select(_database.trackStops)
          ..where((s) => s.trackId.equals(id))
          ..orderBy([(s) => OrderingTerm.asc(s.startedAt)]))
        .get();
    final markerRows = await (_database.select(_database.trackMarkers)
          ..where((m) => m.trackId.equals(id))
          ..orderBy([(m) => OrderingTerm.asc(m.timestamp)]))
        .get();

    return _mapper.trackFromRow(
      row,
      points: pointRows.map(_mapper.pointFromRow).toList(),
      stops: stopRows.map(_mapper.stopFromRow).toList(),
      markers: markerRows.map(_mapper.markerFromRow).toList(),
    );
  }

  Future<void> renameTrack(String id, String name) async {
    await (_database.update(_database.tracks)..where((t) => t.id.equals(id))).write(
      TracksCompanion(name: Value(name)),
    );
  }

  Future<void> deleteTrack(String id) async {
    await (_database.delete(_database.tracks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> discardDraft(String id) async {
    await deleteTrack(id);
  }
}
