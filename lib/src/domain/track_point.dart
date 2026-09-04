/// A single GPS sample on a track.
///
/// Domain-only: no Flutter or plugin types.
class TrackPoint {
  const TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.speed,
    this.accuracy,
  });

  final double latitude;
  final double longitude;
  final double? altitude;

  /// Ground speed in meters per second, when provided by the GPS source.
  final double? speed;

  /// Horizontal accuracy in meters, when provided by the GPS source.
  final double? accuracy;

  final DateTime timestamp;
}
