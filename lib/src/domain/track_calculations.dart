import 'dart:math' as math;

import 'package:geotracker/src/domain/track_point.dart';

/// Pure track math for Stage 0. No Flutter or plugin dependencies.
class TrackCalculations {
  TrackCalculations._();

  static const double _earthRadiusMeters = 6371000;

  /// Great-circle distance between two points in meters (Haversine).
  static double distanceBetween(TrackPoint a, TrackPoint b) {
    final lat1 = _toRadians(a.latitude);
    final lat2 = _toRadians(b.latitude);
    final dLat = _toRadians(b.latitude - a.latitude);
    final dLon = _toRadians(b.longitude - a.longitude);

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return _earthRadiusMeters * c;
  }

  /// Sum of segment distances along [points], in meters.
  static double totalDistanceMeters(List<TrackPoint> points) {
    if (points.length < 2) return 0;
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += distanceBetween(points[i - 1], points[i]);
    }
    return total;
  }

  /// Elapsed time from first to last point, or [Duration.zero] if fewer than 2.
  static Duration durationFromPoints(List<TrackPoint> points) {
    if (points.length < 2) return Duration.zero;
    return points.last.timestamp.difference(points.first.timestamp);
  }

  /// Average speed in m/s from [distanceMeters] and [duration].
  /// Returns 0 when duration is zero.
  static double averageSpeedMps(double distanceMeters, Duration duration) {
    final seconds = duration.inMilliseconds / 1000.0;
    if (seconds <= 0) return 0;
    return distanceMeters / seconds;
  }

  /// Maximum of non-null [TrackPoint.speed] values, in m/s. Returns 0 if none.
  static double maxSpeedMps(List<TrackPoint> points) {
    var max = 0.0;
    for (final point in points) {
      final speed = point.speed;
      if (speed != null && speed > max) {
        max = speed;
      }
    }
    return max;
  }

  /// Cumulative positive altitude change in meters. Null altitudes are skipped.
  static double elevationGainMeters(List<TrackPoint> points) {
    double? previousAltitude;
    var gain = 0.0;
    for (final point in points) {
      final altitude = point.altitude;
      if (altitude == null) {
        continue;
      }
      if (previousAltitude != null) {
        final delta = altitude - previousAltitude;
        if (delta > 0) {
          gain += delta;
        }
      }
      previousAltitude = altitude;
    }
    return gain;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
