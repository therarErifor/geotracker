import 'package:geotracker/src/domain/track_point.dart';

/// A recorded route with aggregate stats and ordered GPS points.
///
/// Domain-only: no Flutter or plugin types.
/// [stops] and [markers] are reserved for later stages.
class Track {
  const Track({
    required this.id,
    required this.name,
    required this.startedAt,
    required this.points,
    this.finishedAt,
    this.duration = Duration.zero,
    this.movingDuration = Duration.zero,
    this.stoppedDuration = Duration.zero,
    this.distanceMeters = 0,
    this.averageSpeedMps = 0,
    this.maxSpeedMps = 0,
    this.elevationGainMeters = 0,
  });

  final String id;
  final String name;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final Duration duration;
  final Duration movingDuration;
  final Duration stoppedDuration;

  /// Total path length in meters.
  final double distanceMeters;

  /// Average speed in meters per second.
  final double averageSpeedMps;

  /// Peak speed in meters per second.
  final double maxSpeedMps;

  /// Cumulative elevation gain in meters.
  final double elevationGainMeters;

  final List<TrackPoint> points;
}
