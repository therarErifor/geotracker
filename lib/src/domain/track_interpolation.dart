import 'package:geotracker/src/domain/track_point.dart';

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

      final spanMilliseconds =
          end.timestamp.difference(start.timestamp).inMilliseconds;
      if (spanMilliseconds <= 0) {
        return _fromPoint(end);
      }
      final progress =
          time.difference(start.timestamp).inMilliseconds / spanMilliseconds;
      return InterpolatedPoint(
        latitude: _lerp(start.latitude, end.latitude, progress),
        longitude: _lerp(start.longitude, end.longitude, progress),
        altitude: _lerpNullable(start.altitude, end.altitude, progress),
        speed: _lerpNullable(start.speed, end.speed, progress),
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

  static double _lerp(double a, double b, double progress) =>
      a + (b - a) * progress;

  static double? _lerpNullable(double? a, double? b, double progress) {
    if (a == null && b == null) {
      return null;
    }
    return _lerp(a ?? b!, b ?? a!, progress);
  }
}
