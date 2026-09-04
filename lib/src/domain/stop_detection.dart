import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/stop.dart';
import 'package:geotracker/src/domain/track_point.dart';

/// Tunable thresholds for automatic stop detection.
class StopDetectionConfig {
  const StopDetectionConfig({
    this.maxSpeedMps = 1 / 3.6,
    this.minDuration = const Duration(seconds: 60),
  });

  /// Speeds strictly below this count as stationary (default 1 km/h).
  final double maxSpeedMps;

  /// Minimum duration for GPS-speed runs and timestamp gaps.
  /// User pauses are always stops, even when shorter.
  final Duration minDuration;
}

/// Builds [Stop] intervals from GPS points and explicit recording pauses.
class StopDetection {
  const StopDetection([this.config = const StopDetectionConfig()]);

  final StopDetectionConfig config;

  List<Stop> detect({
    required List<TrackPoint> points,
    List<PauseInterval> pauseIntervals = const [],
  }) {
    final candidates = <Stop>[
      ..._stopsFromPauses(pauseIntervals),
      ..._stopsFromLowSpeed(points),
      ..._stopsFromTimestampGaps(points),
    ];
    return _mergeOverlapping(candidates);
  }

  static Duration totalDuration(List<Stop> stops) {
    var milliseconds = 0;
    for (final stop in stops) {
      milliseconds += stop.duration.inMilliseconds;
    }
    return Duration(milliseconds: milliseconds);
  }

  List<Stop> _stopsFromPauses(List<PauseInterval> intervals) {
    return [
      for (final interval in intervals)
        if (!interval.finishedAt.isBefore(interval.startedAt))
          Stop(
            startedAt: interval.startedAt,
            finishedAt: interval.finishedAt,
            duration: interval.finishedAt.difference(interval.startedAt),
            latitude: interval.latitude,
            longitude: interval.longitude,
          ),
    ];
  }

  List<Stop> _stopsFromLowSpeed(List<TrackPoint> points) {
    if (points.isEmpty) {
      return const [];
    }

    final stops = <Stop>[];
    var i = 0;
    while (i < points.length) {
      if (!_isLowSpeed(points[i])) {
        i++;
        continue;
      }

      final runStart = i;
      while (i + 1 < points.length && _isLowSpeed(points[i + 1])) {
        i++;
      }
      final runEnd = i;
      final startedAt = points[runStart].timestamp;
      final finishedAt = points[runEnd].timestamp;
      final duration = finishedAt.difference(startedAt);
      if (duration >= config.minDuration) {
        stops.add(
          Stop(
            startedAt: startedAt,
            finishedAt: finishedAt,
            duration: duration,
            latitude: points[runStart].latitude,
            longitude: points[runStart].longitude,
          ),
        );
      }
      i++;
    }
    return stops;
  }

  List<Stop> _stopsFromTimestampGaps(List<TrackPoint> points) {
    if (points.length < 2) {
      return const [];
    }

    final stops = <Stop>[];
    for (var i = 0; i < points.length - 1; i++) {
      final gap = points[i + 1].timestamp.difference(points[i].timestamp);
      if (gap > config.minDuration) {
        stops.add(
          Stop(
            startedAt: points[i].timestamp,
            finishedAt: points[i + 1].timestamp,
            duration: gap,
            latitude: points[i].latitude,
            longitude: points[i].longitude,
          ),
        );
      }
    }
    return stops;
  }

  bool _isLowSpeed(TrackPoint point) {
    final speed = point.speed;
    if (speed == null) {
      return false;
    }
    return speed < config.maxSpeedMps;
  }

  List<Stop> _mergeOverlapping(List<Stop> raw) {
    if (raw.isEmpty) {
      return const [];
    }

    final sorted = [...raw]
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    final merged = <Stop>[];
    var current = sorted.first;

    for (var i = 1; i < sorted.length; i++) {
      final next = sorted[i];
      if (!next.startedAt.isAfter(current.finishedAt)) {
        final finishedAt = next.finishedAt.isAfter(current.finishedAt)
            ? next.finishedAt
            : current.finishedAt;
        current = Stop(
          startedAt: current.startedAt,
          finishedAt: finishedAt,
          duration: finishedAt.difference(current.startedAt),
          latitude: current.latitude,
          longitude: current.longitude,
        );
      } else {
        merged.add(current);
        current = next;
      }
    }
    merged.add(current);
    return merged;
  }
}
