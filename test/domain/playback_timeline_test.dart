import 'package:flutter_test/flutter_test.dart';
import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/playback_timeline.dart';
import 'package:geotracker/src/domain/stop.dart';
import 'package:geotracker/src/domain/track_point.dart';

void main() {
  final startedAt = DateTime.utc(2026, 9, 4, 12);

  TrackPoint point(Duration offset, {double lat = 0, double lon = 0}) {
    return TrackPoint(
      latitude: lat,
      longitude: lon,
      timestamp: startedAt.add(offset),
    );
  }

  group('PlaybackTimeline.wallClockAt', () {
    test('returns startedAt for zero active elapsed', () {
      expect(
        PlaybackTimeline.wallClockAt(
          startedAt: startedAt,
          activeElapsed: Duration.zero,
          pauses: const [],
        ),
        startedAt,
      );
    });

    test('maps active time without pauses as wall clock offset', () {
      expect(
        PlaybackTimeline.wallClockAt(
          startedAt: startedAt,
          activeElapsed: const Duration(minutes: 10),
          pauses: const [],
        ),
        startedAt.add(const Duration(minutes: 10)),
      );
    });

    test('skips pause gaps when mapping active time to wall clock', () {
      final pauses = [
        PauseInterval(
          startedAt: startedAt.add(const Duration(minutes: 10)),
          finishedAt: startedAt.add(const Duration(minutes: 15)),
          latitude: 1,
          longitude: 2,
        ),
      ];

      expect(
        PlaybackTimeline.wallClockAt(
          startedAt: startedAt,
          activeElapsed: const Duration(minutes: 12),
          pauses: pauses,
        ),
        startedAt.add(const Duration(minutes: 17)),
      );
    });

    test('reaches points after a long pause within active duration', () {
      final pauses = [
        PauseInterval(
          startedAt: startedAt.add(const Duration(minutes: 10)),
          finishedAt: startedAt.add(const Duration(minutes: 40)),
          latitude: 1,
          longitude: 2,
        ),
      ];

      final wall = PlaybackTimeline.wallClockAt(
        startedAt: startedAt,
        activeElapsed: const Duration(minutes: 20),
        pauses: pauses,
      );

      expect(wall, startedAt.add(const Duration(minutes: 50)));
    });
  });

  group('PlaybackTimeline.gapIntervals', () {
    test('keeps stops that have no points inside as gap pauses', () {
      final stops = [
        Stop(
          startedAt: startedAt.add(const Duration(minutes: 5)),
          finishedAt: startedAt.add(const Duration(minutes: 10)),
          duration: const Duration(minutes: 5),
          latitude: 10,
          longitude: 20,
        ),
      ];
      final points = [
        point(Duration.zero),
        point(const Duration(minutes: 5)),
        point(const Duration(minutes: 10)),
      ];

      final gaps = PlaybackTimeline.gapIntervals(stops: stops, points: points);
      expect(gaps, hasLength(1));
      expect(gaps.first.startedAt, stops.first.startedAt);
    });

    test('drops low-speed stops that contain points', () {
      final stops = [
        Stop(
          startedAt: startedAt,
          finishedAt: startedAt.add(const Duration(minutes: 2)),
          duration: const Duration(minutes: 2),
          latitude: 10,
          longitude: 20,
        ),
      ];
      final points = [
        point(Duration.zero),
        point(const Duration(minutes: 1), lat: 10.001),
        point(const Duration(minutes: 2)),
      ];

      expect(
        PlaybackTimeline.gapIntervals(stops: stops, points: points),
        isEmpty,
      );
    });
  });
}
