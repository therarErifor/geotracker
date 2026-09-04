import 'package:flutter_test/flutter_test.dart';
import 'package:geotracker/src/domain/gps_filter.dart';
import 'package:geotracker/src/domain/track_point.dart';

void main() {
  const filter = GpsFilter();
  final t0 = DateTime.utc(2026, 1, 1, 12);

  group('GpsFilter.shouldAccept', () {
    test('accepts first point with good accuracy', () {
      final point = _point(55.75, 37.62, t0, accuracy: 10);
      expect(filter.shouldAccept(point, null), isTrue);
    });

    test('rejects first point with poor accuracy', () {
      final point = _point(55.75, 37.62, t0, accuracy: 50);
      expect(filter.shouldAccept(point, null), isFalse);
    });

    test('accepts first point when accuracy is unknown', () {
      final point = _point(55.75, 37.62, t0);
      expect(filter.shouldAccept(point, null), isTrue);
    });

    test('rejects point too soon after last accepted', () {
      final last = _point(55.75, 37.62, t0, accuracy: 10);
      final next = _point(55.751, 37.62, t0.add(const Duration(milliseconds: 500)),
          accuracy: 10);
      expect(filter.shouldAccept(next, last), isFalse);
    });

    test('rejects point too close to last accepted', () {
      final last = _point(55.75, 37.62, t0, accuracy: 10);
      final next = _point(55.75001, 37.62, t0.add(const Duration(seconds: 2)),
          accuracy: 10);
      expect(filter.shouldAccept(next, last), isFalse);
    });

    test('accepts point that moved enough after interval', () {
      final last = _point(55.75, 37.62, t0, accuracy: 10);
      final next = _point(55.7505, 37.62, t0.add(const Duration(seconds: 5)),
          accuracy: 10);
      expect(filter.shouldAccept(next, last), isTrue);
    });

    test('rejects implausible speed outlier', () {
      const strictFilter = GpsFilter(
        GpsFilterConfig(
          minDistanceMeters: 1,
          minInterval: Duration(seconds: 1),
          maxImpliedSpeedMps: 10,
        ),
      );
      final last = _point(55.75, 37.62, t0, accuracy: 5);
      final next = _point(55.85, 37.62, t0.add(const Duration(seconds: 1)),
          accuracy: 5);
      expect(strictFilter.shouldAccept(next, last), isFalse);
    });
  });
}

TrackPoint _point(
  double lat,
  double lon,
  DateTime timestamp, {
  double? accuracy,
}) {
  return TrackPoint(
    latitude: lat,
    longitude: lon,
    timestamp: timestamp,
    accuracy: accuracy,
  );
}
