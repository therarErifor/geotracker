import 'package:flutter_test/flutter_test.dart';
import 'package:geotracker/src/domain/track_interpolation.dart';
import 'package:geotracker/src/domain/track_point.dart';

void main() {
  final t0 = DateTime.utc(2026, 9, 4, 12);

  TrackPoint point(double lat, double lon, Duration offset, {double? speed}) {
    return TrackPoint(
      latitude: lat,
      longitude: lon,
      timestamp: t0.add(offset),
      speed: speed,
    );
  }

  group('TrackInterpolation.at', () {
    test('returns null for an empty point list', () {
      expect(TrackInterpolation.at(const [], t0), isNull);
    });

    test('returns the only point for a single-point track', () {
      final points = [point(10, 20, Duration.zero, speed: 3)];
      final result = TrackInterpolation.at(
        points,
        t0.add(const Duration(seconds: 10)),
      );
      expect(result, isNotNull);
      expect(result!.latitude, 10);
      expect(result.longitude, 20);
      expect(result.speed, 3);
    });

    test('clamps to the first point before the track starts', () {
      final points = [
        point(1, 2, Duration.zero),
        point(3, 4, const Duration(seconds: 10)),
      ];
      final result = TrackInterpolation.at(
        points,
        t0.subtract(const Duration(seconds: 5)),
      );
      expect(result!.latitude, 1);
      expect(result.longitude, 2);
    });

    test('clamps to the last point after the track ends', () {
      final points = [
        point(1, 2, Duration.zero),
        point(3, 4, const Duration(seconds: 10)),
      ];
      final result = TrackInterpolation.at(
        points,
        t0.add(const Duration(seconds: 20)),
      );
      expect(result!.latitude, 3);
      expect(result.longitude, 4);
    });

    test('lerps the midpoint of a segment', () {
      final points = [
        point(0, 0, Duration.zero, speed: 0),
        point(10, 20, const Duration(seconds: 10), speed: 10),
      ];
      final result = TrackInterpolation.at(
        points,
        t0.add(const Duration(seconds: 5)),
      );
      expect(result!.latitude, closeTo(5, 0.0001));
      expect(result.longitude, closeTo(10, 0.0001));
      expect(result.speed, closeTo(5, 0.0001));
    });
  });
}
