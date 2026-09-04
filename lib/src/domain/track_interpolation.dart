import 'package:geotracker/src/domain/track_point.dart';

/// A position on a track at an arbitrary playback instant.
class InterpolatedPoint {
  const InterpolatedPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
  });

  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
}

/// Linear interpolation of [TrackPoint]s by timestamp.
class TrackInterpolation {
  const TrackInterpolation._();

  static InterpolatedPoint? at(List<TrackPoint> points, DateTime time) {
    if (points.isEmpty) {
      return null;
    }
    if (points.length == 1 || !time.isAfter(points.first.timestamp)) {
      return _fromPoint(points.first);
    }
    if (!time.isBefore(points.last.timestamp)) {
      return _fromPoint(points.last);
    }

    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      if (time.isBefore(start.timestamp)) {
        return _fromPoint(start);
      }
      if (time.isAfter(end.timestamp)) {
        continue;
      }

      final spanMs = end.timestamp.difference(start.timestamp).inMilliseconds;
      if (spanMs <= 0) {
        return _fromPoint(end);
      }
      final t = time.difference(start.timestamp).inMilliseconds / spanMs;
      return InterpolatedPoint(
        latitude: _lerp(start.latitude, end.latitude, t),
        longitude: _lerp(start.longitude, end.longitude, t),
        altitude: _lerpNullable(start.altitude, end.altitude, t),
        speed: _lerpNullable(start.speed, end.speed, t),
      );
    }

    return _fromPoint(points.last);
  }

  static InterpolatedPoint _fromPoint(TrackPoint point) {
    return InterpolatedPoint(
      latitude: point.latitude,
      longitude: point.longitude,
      altitude: point.altitude,
      speed: point.speed,
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static double? _lerpNullable(double? a, double? b, double t) {
    if (a == null && b == null) {
      return null;
    }
    return _lerp(a ?? b!, b ?? a!, t);
  }
}
