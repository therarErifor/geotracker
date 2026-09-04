import 'package:drift/drift.dart';
import 'package:geotracker/src/data/local/app_database.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_point.dart';

/// Maps between domain [Track]/[TrackPoint] and Drift companions/rows.
class TrackMapper {
  const TrackMapper();

  TracksCompanion trackToCompanion(Track track) {
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
    );
  }

  List<TrackPointsCompanion> pointsToCompanions(
    String trackId,
    List<TrackPoint> points,
  ) {
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
          orderIndex: i,
        ),
    ];
  }

  Track trackFromRow(TrackRow row, {List<TrackPoint> points = const []}) {
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
}
