import 'package:flutter_test/flutter_test.dart';
import 'package:geotracker/src/domain/course.dart';
import 'package:geotracker/src/domain/track_point.dart';

void main() {
  group('Course.resolveCourseDegrees', () {
    test('uses gps heading when speed is high enough', () {
      expect(
        Course.resolveCourseDegrees(gpsHeading: 270, speedMps: 1.2),
        270,
      );
    });

    test('keeps previous course when standing still even if heading is 0', () {
      expect(
        Course.resolveCourseDegrees(
          gpsHeading: 0,
          speedMps: 0,
          previousCourseDegrees: 90,
        ),
        90,
      );
    });

    test('returns null when standing still and there is no previous course', () {
      expect(
        Course.resolveCourseDegrees(gpsHeading: 0, speedMps: 0),
        isNull,
      );
    });

    test('falls back to bearing when points are far enough', () {
      final from = TrackPoint(
        latitude: 0,
        longitude: 0,
        timestamp: DateTime.utc(2026, 1, 1),
      );
      final to = TrackPoint(
        latitude: 0,
        longitude: 0.001,
        timestamp: DateTime.utc(2026, 1, 1, 0, 0, 2),
      );
      expect(
        Course.resolveCourseDegrees(
          gpsHeading: 0,
          speedMps: 0,
          from: from,
          to: to,
          minDistanceMeters: Course.recordingMinDistanceMeters,
        ),
        closeTo(90, 0.5),
      );
    });

    test('keeps previous course when displacement is below the threshold', () {
      final from = TrackPoint(
        latitude: 0,
        longitude: 0,
        timestamp: DateTime.utc(2026, 1, 1),
      );
      final to = TrackPoint(
        latitude: 0,
        longitude: 0.00001,
        timestamp: DateTime.utc(2026, 1, 1, 0, 0, 2),
      );
      expect(
        Course.resolveCourseDegrees(
          from: from,
          to: to,
          minDistanceMeters: Course.restMinDistanceMeters,
          previousCourseDegrees: 12,
        ),
        12,
      );
    });
  });
}
