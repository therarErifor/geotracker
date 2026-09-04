import 'package:flutter_test/flutter_test.dart';
import 'package:geotracker/src/domain/track_calculations.dart';
import 'package:geotracker/src/domain/track_point.dart';

void main() {
  group('TrackCalculations.distanceBetween', () {
    test('returns ~0 for identical points', () {
      final point = _point(55.75, 37.62, DateTime.utc(2026, 1, 1));
      expect(TrackCalculations.distanceBetween(point, point), closeTo(0, 0.01));
    });

    test('returns ~111.2 km for 1 degree latitude at equator', () {
      final a = _point(0, 0, DateTime.utc(2026, 1, 1));
      final b = _point(1, 0, DateTime.utc(2026, 1, 1));
      // 1° latitude ≈ 111.2 km
      expect(
        TrackCalculations.distanceBetween(a, b),
        closeTo(111195, 200),
      );
    });
  });

  group('TrackCalculations.totalDistanceMeters', () {
    test('returns 0 for empty or single point', () {
      expect(TrackCalculations.totalDistanceMeters(const []), 0);
      expect(
        TrackCalculations.totalDistanceMeters([
          _point(0, 0, DateTime.utc(2026, 1, 1)),
        ]),
        0,
      );
    });

    test('sums consecutive segments', () {
      final t0 = DateTime.utc(2026, 1, 1);
      final points = [
        _point(0, 0, t0),
        _point(0, 0.001, t0.add(const Duration(seconds: 10))),
        _point(0, 0.002, t0.add(const Duration(seconds: 20))),
      ];
      final total = TrackCalculations.totalDistanceMeters(points);
      final first = TrackCalculations.distanceBetween(points[0], points[1]);
      final second = TrackCalculations.distanceBetween(points[1], points[2]);
      expect(total, closeTo(first + second, 0.01));
    });
  });

  group('TrackCalculations.durationFromPoints', () {
    test('returns zero for fewer than 2 points', () {
      expect(TrackCalculations.durationFromPoints(const []), Duration.zero);
      expect(
        TrackCalculations.durationFromPoints([
          _point(0, 0, DateTime.utc(2026, 1, 1)),
        ]),
        Duration.zero,
      );
    });

    test('returns difference between first and last timestamp', () {
      final t0 = DateTime.utc(2026, 1, 1, 12);
      final points = [
        _point(0, 0, t0),
        _point(0, 0.001, t0.add(const Duration(minutes: 5))),
      ];
      expect(
        TrackCalculations.durationFromPoints(points),
        const Duration(minutes: 5),
      );
    });
  });

  group('TrackCalculations.averageSpeedMps', () {
    test('returns 0 for zero duration', () {
      expect(TrackCalculations.averageSpeedMps(100, Duration.zero), 0);
    });

    test('computes distance / time', () {
      // 100 m in 10 s → 10 m/s
      expect(
        TrackCalculations.averageSpeedMps(100, const Duration(seconds: 10)),
        closeTo(10, 0.001),
      );
    });
  });

  group('TrackCalculations.maxSpeedMps', () {
    test('returns 0 when no speeds', () {
      expect(
        TrackCalculations.maxSpeedMps([
          _point(0, 0, DateTime.utc(2026, 1, 1)),
        ]),
        0,
      );
    });

    test('returns maximum provided speed', () {
      final t0 = DateTime.utc(2026, 1, 1);
      expect(
        TrackCalculations.maxSpeedMps([
          _point(0, 0, t0, speed: 2),
          _point(0, 0.001, t0.add(const Duration(seconds: 1)), speed: 5.5),
          _point(0, 0.002, t0.add(const Duration(seconds: 2)), speed: 3),
        ]),
        5.5,
      );
    });
  });

  group('TrackCalculations.elevationGainMeters', () {
    test('returns 0 when no altitudes', () {
      final t0 = DateTime.utc(2026, 1, 1);
      expect(
        TrackCalculations.elevationGainMeters([
          _point(0, 0, t0),
          _point(0, 0.001, t0.add(const Duration(seconds: 1))),
        ]),
        0,
      );
    });

    test('sums only positive altitude deltas', () {
      final t0 = DateTime.utc(2026, 1, 1);
      expect(
        TrackCalculations.elevationGainMeters([
          _point(0, 0, t0, altitude: 100),
          _point(0, 0.001, t0.add(const Duration(seconds: 1)), altitude: 120),
          _point(0, 0.002, t0.add(const Duration(seconds: 2)), altitude: 110),
          _point(0, 0.003, t0.add(const Duration(seconds: 3)), altitude: 130),
        ]),
        closeTo(40, 0.001),
      );
    });

    test('skips null altitudes without breaking the chain', () {
      final t0 = DateTime.utc(2026, 1, 1);
      expect(
        TrackCalculations.elevationGainMeters([
          _point(0, 0, t0, altitude: 100),
          _point(0, 0.001, t0.add(const Duration(seconds: 1))),
          _point(0, 0.002, t0.add(const Duration(seconds: 2)), altitude: 115),
        ]),
        closeTo(15, 0.001),
      );
    });
  });
}

TrackPoint _point(
  double lat,
  double lon,
  DateTime timestamp, {
  double? speed,
  double? altitude,
}) {
  return TrackPoint(
    latitude: lat,
    longitude: lon,
    timestamp: timestamp,
    speed: speed,
    altitude: altitude,
  );
}
