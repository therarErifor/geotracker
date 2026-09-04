import 'package:geotracker/src/data/datasources/local_track_datasource.dart';
import 'package:geotracker/src/data/repositories/track_repository.dart';
import 'package:geotracker/src/domain/marker.dart';
import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/recording_draft.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_point.dart';
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

  @override
  Future<void> createDraft({
    required String id,
    required String name,
    required DateTime startedAt,
    required String recordingStatus,
  }) =>
      _dataSource.createDraft(
        id: id,
        name: name,
        startedAt: startedAt,
        recordingStatus: recordingStatus,
      );

  @override
  Future<void> updateDraftMeta({
    required String id,
    required String recordingStatus,
    required List<PauseInterval> pauseIntervals,
    required Duration totalPausedDuration,
    DateTime? openPauseStartedAt,
    double? distanceMeters,
    int? durationMs,
  }) =>
      _dataSource.updateDraftMeta(
        id: id,
        recordingStatus: recordingStatus,
        pauseIntervals: pauseIntervals,
        totalPausedDuration: totalPausedDuration,
        openPauseStartedAt: openPauseStartedAt,
        distanceMeters: distanceMeters,
        durationMs: durationMs,
      );

  @override
  Future<void> appendPoints({
    required String trackId,
    required List<TrackPoint> points,
    required int startOrderIndex,
  }) =>
      _dataSource.appendPoints(
        trackId: trackId,
        points: points,
        startOrderIndex: startOrderIndex,
      );

  @override
  Future<void> replaceMarkers({
    required String trackId,
    required List<Marker> markers,
  }) =>
      _dataSource.replaceMarkers(trackId: trackId, markers: markers);

  @override
  Future<RecordingDraft?> getActiveDraft() => _dataSource.getActiveDraft();

  @override
  Future<void> finalizeTrack(Track track) => _dataSource.finalizeTrack(track);

  @override
  Future<void> discardDraft(String id) => _dataSource.discardDraft(id);
}
