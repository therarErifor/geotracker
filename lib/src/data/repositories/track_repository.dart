import 'package:geotracker/src/domain/marker.dart';
import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/recording_draft.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_point.dart';

abstract class TrackRepository {
  Future<void> save(Track track);

  Future<List<Track>> getSummaries();

  Future<Track?> getById(String id);

  Future<void> rename(String id, String name);

  Future<void> delete(String id);

  Future<void> createDraft({
    required String id,
    required String name,
    required DateTime startedAt,
    required String recordingStatus,
  });

  Future<void> updateDraftMeta({
    required String id,
    required String recordingStatus,
    required List<PauseInterval> pauseIntervals,
    required Duration totalPausedDuration,
    DateTime? openPauseStartedAt,
    double? distanceMeters,
    int? durationMs,
  });

  Future<void> appendPoints({
    required String trackId,
    required List<TrackPoint> points,
    required int startOrderIndex,
  });

  Future<void> replaceMarkers({
    required String trackId,
    required List<Marker> markers,
  });

  Future<RecordingDraft?> getActiveDraft();

  Future<void> finalizeTrack(Track track);

  Future<void> discardDraft(String id);
}
