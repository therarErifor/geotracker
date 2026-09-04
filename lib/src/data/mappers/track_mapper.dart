import 'package:drift/drift.dart';
import 'package:geotracker/src/data/local/app_database.dart';
import 'package:geotracker/src/data/mappers/pause_interval_codec.dart';
import 'package:geotracker/src/domain/marker.dart';
import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/stop.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_point.dart';

/// Maps between domain [Track]/[TrackPoint] and Drift companions/rows.
class TrackMapper {
  const TrackMapper([this._pauseCodec = const PauseIntervalCodec()]);

  final PauseIntervalCodec _pauseCodec;

  TracksCompanion trackToCompanion(
    Track track, {
    String? recordingStatus,
    List<PauseInterval> pauseIntervals = const [],
    Duration totalPausedDuration = Duration.zero,
    DateTime? openPauseStartedAt,
  }) {
    final pauseJson = recordingStatus == null
        ? const Value<String?>.absent()
        : Value(
            _pauseCodec.encode(
              intervals: pauseIntervals,
              totalPausedDuration: totalPausedDuration,
              openPauseStartedAt: openPauseStartedAt,
            ),
          );

    return TracksCompanion.insert(
      id: track.id,
      name: track.name,
      startedAt: track.startedAt,
      finishedAt: Value(track.finishedAt),
      durationMs: Value(track.duration.inMilliseconds),
      movingDurationMs: Value(track.movingDuration.inMilliseconds),
      stoppedDurationMs: Value(track.stoppedDuration.inMilliseconds),
      distanceMeters: Value(track.distanceMeters),
      averageSpeedMps: Value(track.averageSpeedMps),
      maxSpeedMps: Value(track.maxSpeedMps),
      elevationGainMeters: Value(track.elevationGainMeters),
      recordingStatus: Value(recordingStatus),
      pauseIntervalsJson: pauseJson,
    );
  }

  List<TrackPointsCompanion> pointsToCompanions(
    String trackId,
    List<TrackPoint> points, {
    int startOrderIndex = 0,
  }) {
    return [
      for (var i = 0; i < points.length; i++)
        TrackPointsCompanion.insert(
          trackId: trackId,
          latitude: points[i].latitude,
          longitude: points[i].longitude,
          altitude: Value(points[i].altitude),
          speed: Value(points[i].speed),
          accuracy: Value(points[i].accuracy),
          timestamp: points[i].timestamp,
          orderIndex: startOrderIndex + i,
        ),
    ];
  }

  List<TrackStopsCompanion> stopsToCompanions(
    String trackId,
    List<Stop> stops,
  ) {
    return [
      for (final stop in stops)
        TrackStopsCompanion.insert(
          trackId: trackId,
          startedAt: stop.startedAt,
          finishedAt: stop.finishedAt,
          durationMs: stop.duration.inMilliseconds,
          latitude: stop.latitude,
          longitude: stop.longitude,
        ),
    ];
  }

  List<TrackMarkersCompanion> markersToCompanions(
    String trackId,
    List<Marker> markers,
  ) {
    return [
      for (final marker in markers)
        TrackMarkersCompanion.insert(
          id: marker.id,
          trackId: trackId,
          latitude: marker.latitude,
          longitude: marker.longitude,
          timestamp: marker.timestamp,
          title: marker.title,
          description: marker.description,
        ),
    ];
  }

  Track trackFromRow(
    TrackRow row, {
    List<TrackPoint> points = const [],
    List<Stop> stops = const [],
    List<Marker> markers = const [],
  }) {
    return Track(
      id: row.id,
      name: row.name,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      duration: Duration(milliseconds: row.durationMs),
      movingDuration: Duration(milliseconds: row.movingDurationMs),
      stoppedDuration: Duration(milliseconds: row.stoppedDurationMs),
      distanceMeters: row.distanceMeters,
      averageSpeedMps: row.averageSpeedMps,
      maxSpeedMps: row.maxSpeedMps,
      elevationGainMeters: row.elevationGainMeters,
      points: points,
      stops: stops,
      markers: markers,
    );
  }

  TrackPoint pointFromRow(TrackPointRow row) {
    return TrackPoint(
      latitude: row.latitude,
      longitude: row.longitude,
      altitude: row.altitude,
      speed: row.speed,
      accuracy: row.accuracy,
      timestamp: row.timestamp,
    );
  }

  Stop stopFromRow(StopRow row) {
    return Stop(
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      duration: Duration(milliseconds: row.durationMs),
      latitude: row.latitude,
      longitude: row.longitude,
    );
  }

  Marker markerFromRow(MarkerRow row) {
    return Marker(
      id: row.id,
      latitude: row.latitude,
      longitude: row.longitude,
      timestamp: row.timestamp,
      title: row.title,
      description: row.description,
    );
  }

  String encodePauseMeta({
    required List<PauseInterval> intervals,
    required Duration totalPausedDuration,
    DateTime? openPauseStartedAt,
  }) {
    return _pauseCodec.encode(
      intervals: intervals,
      totalPausedDuration: totalPausedDuration,
      openPauseStartedAt: openPauseStartedAt,
    );
  }

  ({
    List<PauseInterval> intervals,
    Duration totalPausedDuration,
    DateTime? openPauseStartedAt,
  }) decodePauseMeta(String? raw) {
    return _pauseCodec.decode(raw);
  }
}
