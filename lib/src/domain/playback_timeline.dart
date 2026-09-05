import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/stop.dart';
import 'package:geotracker/src/domain/track_point.dart';

class PlaybackTimeline {
  const PlaybackTimeline._();

  static List<PauseInterval> gapIntervals({
    required List<Stop> stops,
    required List<TrackPoint> points,
  }) {
    return [
      for (final stop in stops)
        if (!_hasPointInside(points, stop))
          PauseInterval(
            startedAt: stop.startedAt,
            finishedAt: stop.finishedAt,
            latitude: stop.latitude,
            longitude: stop.longitude,
          ),
    ]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  }

  static DateTime wallClockAt({
    required DateTime startedAt,
    required Duration activeElapsed,
    required List<PauseInterval> pauses,
  }) {
    if (activeElapsed <= Duration.zero) {
      return startedAt;
    }

    final sorted = List<PauseInterval>.from(pauses)
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    var cursor = startedAt;
    var remaining = activeElapsed;

    for (final pause in sorted) {
      if (!pause.finishedAt.isAfter(pause.startedAt)) {
        continue;
      }
      if (!pause.startedAt.isAfter(cursor)) {
        if (pause.finishedAt.isAfter(cursor)) {
          cursor = pause.finishedAt;
        }
        continue;
      }

      final segmentLength = pause.startedAt.difference(cursor);
      if (remaining <= segmentLength) {
        return cursor.add(remaining);
      }
      remaining -= segmentLength;
      cursor = pause.finishedAt;
    }

    return cursor.add(remaining);
  }

  static bool _hasPointInside(List<TrackPoint> points, Stop stop) {
    for (final point in points) {
      if (point.timestamp.isAfter(stop.startedAt) &&
          point.timestamp.isBefore(stop.finishedAt)) {
        return true;
      }
    }
    return false;
  }
}
