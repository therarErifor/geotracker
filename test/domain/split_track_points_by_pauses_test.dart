import 'package:flutter_test/flutter_test.dart';
import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/split_track_points_by_pauses.dart';
import 'package:geotracker/src/domain/track_point.dart';

void main() {
  final t0 = DateTime.utc(2026, 1, 1, 12);

  TrackPoint point(double lat, DateTime time) {
    return TrackPoint(latitude: lat, longitude: 37.62, timestamp: time);
  }

  test('returns empty list when there are no points', () {
    expect(splitTrackPointsByPauses(const [], const []), isEmpty);
  });

  test('returns one segment when there are no pauses', () {
    final points = [
      point(55.75, t0),
      point(55.76, t0.add(const Duration(seconds: 10))),
    ];
    final segments = splitTrackPointsByPauses(points, const []);
    expect(segments, hasLength(1));
    expect(segments.single, points);
  });

  test('splits into two segments across a pause without a chord', () {
    final before = point(55.75, t0);
    final after = point(55.80, t0.add(const Duration(minutes: 10)));
    final pause = PauseInterval(
      startedAt: t0.add(const Duration(minutes: 1)),
      finishedAt: t0.add(const Duration(minutes: 9)),
      latitude: 55.75,
      longitude: 37.62,
      pointCountAtStart: 1,
    );

    final segments = splitTrackPointsByPauses([before, after], [pause]);
    expect(segments, hasLength(2));
    expect(segments[0], [before]);
    expect(segments[1], [after]);
  });

  test('keeps a single-point segment when resume has only one accepted point',
      () {
    final a = point(55.75, t0);
    final b = point(55.76, t0.add(const Duration(seconds: 20)));
    final c = point(55.90, t0.add(const Duration(minutes: 5)));
    final pause = PauseInterval(
      startedAt: t0.add(const Duration(minutes: 1)),
      finishedAt: t0.add(const Duration(minutes: 4)),
      latitude: 55.76,
      longitude: 37.62,
      pointCountAtStart: 2,
    );

    final segments = splitTrackPointsByPauses([a, b, c], [pause]);
    expect(segments, hasLength(2));
    expect(segments[0], [a, b]);
    expect(segments[1], [c]);
  });

  test('splits by point count even when GPS timestamps miss the pause window',
      () {
    final before = point(55.75, t0.add(const Duration(hours: 2)));
    final after = point(55.80, t0.add(const Duration(hours: 2, minutes: 1)));
    final pause = PauseInterval(
      startedAt: t0,
      finishedAt: t0.add(const Duration(minutes: 5)),
      latitude: 55.75,
      longitude: 37.62,
      pointCountAtStart: 1,
    );

    final segments = splitTrackPointsByPauses([before, after], [pause]);
    expect(segments, hasLength(2));
    expect(segments[0], [before]);
    expect(segments[1], [after]);
  });

  test('falls back to timestamps when point count is missing', () {
    final a = point(55.75, t0);
    final inside = point(55.77, t0.add(const Duration(minutes: 2)));
    final c = point(55.90, t0.add(const Duration(minutes: 5)));
    final pause = PauseInterval(
      startedAt: t0.add(const Duration(minutes: 1)),
      finishedAt: t0.add(const Duration(minutes: 4)),
      latitude: 55.75,
      longitude: 37.62,
    );

    final segments = splitTrackPointsByPauses([a, inside, c], [pause]);
    expect(segments, hasLength(2));
    expect(segments[0], [a]);
    expect(segments[1], [c]);
  });
}
