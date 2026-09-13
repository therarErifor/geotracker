import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/track_point.dart';

List<List<TrackPoint>> splitTrackPointsByPauses(
  List<TrackPoint> points,
  List<PauseInterval> intervals,
) {
  if (points.isEmpty) {
    return const [];
  }
  if (intervals.isEmpty) {
    return [List<TrackPoint>.unmodifiable(points)];
  }

  final counts = <int>[
    for (final interval in intervals)
      if (interval.pointCountAtStart != null) interval.pointCountAtStart!,
  ];
  if (counts.length == intervals.length) {
    return _splitByPointCounts(points, counts);
  }
  return _splitByTimestamps(points, intervals);
}

List<List<TrackPoint>> _splitByPointCounts(
  List<TrackPoint> points,
  List<int> counts,
) {
  final cuts = counts.toSet().toList()..sort();
  final segments = <List<TrackPoint>>[];
  var start = 0;
  for (final cut in cuts) {
    if (cut <= start || cut > points.length) {
      continue;
    }
    segments.add(List<TrackPoint>.unmodifiable(points.sublist(start, cut)));
    start = cut;
  }
  if (start < points.length) {
    segments.add(List<TrackPoint>.unmodifiable(points.sublist(start)));
  }
  return segments;
}

List<List<TrackPoint>> _splitByTimestamps(
  List<TrackPoint> points,
  List<PauseInterval> intervals,
) {
  final pauses = List<PauseInterval>.from(intervals)
    ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

  final segments = <List<TrackPoint>>[];
  var current = <TrackPoint>[];

  for (final point in points) {
    if (_isInsidePause(point.timestamp, pauses)) {
      if (current.isNotEmpty) {
        segments.add(current);
        current = <TrackPoint>[];
      }
      continue;
    }

    if (current.isEmpty) {
      current.add(point);
      continue;
    }

    if (_crossesPause(current.last.timestamp, point.timestamp, pauses)) {
      segments.add(current);
      current = <TrackPoint>[point];
      continue;
    }

    current.add(point);
  }

  if (current.isNotEmpty) {
    segments.add(current);
  }

  return [
    for (final segment in segments) List<TrackPoint>.unmodifiable(segment),
  ];
}

bool _isInsidePause(DateTime timestamp, List<PauseInterval> pauses) {
  for (final pause in pauses) {
    if (!timestamp.isBefore(pause.startedAt) &&
        timestamp.isBefore(pause.finishedAt)) {
      return true;
    }
  }
  return false;
}

bool _crossesPause(
  DateTime previous,
  DateTime next,
  List<PauseInterval> pauses,
) {
  for (final pause in pauses) {
    if (!previous.isAfter(pause.startedAt) &&
        !next.isBefore(pause.finishedAt)) {
      return true;
    }
  }
  return false;
}
