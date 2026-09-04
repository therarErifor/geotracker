import 'package:geotracker/src/domain/track_calculations.dart';
import 'package:geotracker/src/domain/track_point.dart';

/// Tunable thresholds for basic GPS point acceptance.
class GpsFilterConfig {
  const GpsFilterConfig({
    this.maxAccuracyMeters = 30,
    this.minDistanceMeters = 3,
    this.minInterval = const Duration(seconds: 1),
    this.maxImpliedSpeedMps = 55,
  });

  /// Reject points with horizontal accuracy worse than this (meters).
  final double maxAccuracyMeters;

  /// Minimum movement from the last accepted point (meters).
  final double minDistanceMeters;

  /// Minimum time between accepted points.
  final Duration minInterval;

  /// Reject jumps that imply speed above this (m/s), ~200 km/h by default.
  final double maxImpliedSpeedMps;
}

/// Pure GPS filtering — no Flutter or plugin dependencies.
class GpsFilter {
  const GpsFilter([this.config = const GpsFilterConfig()]);

  final GpsFilterConfig config;

  /// Returns true when [candidate] should be appended to the track.
  bool shouldAccept(TrackPoint candidate, TrackPoint? lastAccepted) {
    if (!_hasAcceptableAccuracy(candidate)) {
      return false;
    }
    if (lastAccepted == null) {
      return true;
    }

    final elapsed = candidate.timestamp.difference(lastAccepted.timestamp);
    if (elapsed < config.minInterval) {
      return false;
    }

    final distance = TrackCalculations.distanceBetween(lastAccepted, candidate);
    if (distance < config.minDistanceMeters) {
      return false;
    }

    final elapsedSeconds = elapsed.inMilliseconds / 1000.0;
    if (elapsedSeconds > 0) {
      final impliedSpeed = distance / elapsedSeconds;
      if (impliedSpeed > config.maxImpliedSpeedMps) {
        return false;
      }
    }

    return true;
  }

  bool _hasAcceptableAccuracy(TrackPoint point) {
    final accuracy = point.accuracy;
    if (accuracy == null) {
      return true;
    }
    return accuracy <= config.maxAccuracyMeters;
  }
}
