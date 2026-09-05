import 'package:geotracker/src/domain/marker.dart';
import 'package:geotracker/src/domain/stop.dart';
import 'package:geotracker/src/domain/track_point.dart';

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
    this.stops = const [],
    this.markers = const [],
  });

  final String id;
  final String name;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final Duration duration;
  final Duration movingDuration;
  final Duration stoppedDuration;
  final double distanceMeters;
  final double averageSpeedMps;
  final double maxSpeedMps;
  final double elevationGainMeters;
  final List<TrackPoint> points;
  final List<Stop> stops;
  final List<Marker> markers;
}
