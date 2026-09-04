import 'package:flutter_test/flutter_test.dart';
import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/stop_detection.dart';
import 'package:geotracker/src/domain/track_point.dart';

void main() {
  const detection = StopDetection();
  final t0 = DateTime.utc(2026, 9, 4, 10);

  TrackPoint point({
    required Duration offset,
    double lat = 55.75,
    double lon = 37.62,
    double? speed,
  }) {
    return TrackPoint(
      latitude: lat,
      longitude: lon,
      timestamp: t0.add(offset),
      speed: speed,
    );
  }

  group('StopDetection', () {
    test('treats a user pause as a stop even when shorter than 60s', () {
      final stops = detection.detect(
        points: [
          point(offset: Duration.zero, speed: 5),
          point(offset: const Duration(seconds: 10), speed: 5),
        ],
        pauseIntervals: [
          PauseInterval(
            startedAt: t0.add(const Duration(seconds: 10)),
            finishedAt: t0.add(const Duration(seconds: 25)),
            latitude: 55.75,
            longitude: 37.62,
          ),
        ],
      );

      expect(stops, hasLength(1));
      expect(stops.first.duration, const Duration(seconds: 15));
    });

    test('detects a low-speed run longer than the minimum duration', () {
      const low = 0.1;
      final points = [
        point(offset: Duration.zero, speed: low),
        point(offset: const Duration(seconds: 30), speed: low),
        point(offset: const Duration(seconds: 70), speed: low),
      ];

      final stops = detection.detect(points: points);
      expect(stops, hasLength(1));
      expect(stops.first.duration, const Duration(seconds: 70));
      expect(stops.first.latitude, 55.75);
    });

    test('does not treat null speed as a low-speed stop', () {
      final points = [
        point(offset: Duration.zero),
        point(offset: const Duration(seconds: 30)),
        point(offset: const Duration(seconds: 70)),
      ];

      expect(detection.detect(points: points), isEmpty);
    });

    test('detects a timestamp gap longer than 60s', () {
      final points = [
        point(offset: Duration.zero, speed: 4),
        point(offset: const Duration(seconds: 90), lat: 55.76, speed: 4),
      ];

      final stops = detection.detect(points: points);
      expect(stops, hasLength(1));
      expect(stops.first.duration, const Duration(seconds: 90));
      expect(stops.first.latitude, 55.75);
    });

    test('does not flag a 60s gap (threshold is strictly greater)', () {
      final points = [
        point(offset: Duration.zero, speed: 4),
        point(offset: const Duration(seconds: 60), speed: 4),
      ];

      expect(detection.detect(points: points), isEmpty);
    });

    test('merges overlapping pause and gap intervals', () {
      final points = [
        point(offset: Duration.zero, speed: 4),
        point(offset: const Duration(seconds: 120), lat: 55.76, speed: 4),
      ];
      final stops = detection.detect(
        points: points,
        pauseIntervals: [
          PauseInterval(
            startedAt: t0.add(const Duration(seconds: 10)),
            finishedAt: t0.add(const Duration(seconds: 80)),
            latitude: 55.75,
            longitude: 37.62,
          ),
        ],
      );

      expect(stops, hasLength(1));
      expect(stops.first.startedAt, t0);
      expect(stops.first.finishedAt, t0.add(const Duration(seconds: 120)));
      expect(stops.first.duration, const Duration(seconds: 120));
    });
  });
}
