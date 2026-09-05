import 'package:geotracker/src/domain/track_calculations.dart';
import 'package:geotracker/src/domain/track_point.dart';

class GpsFilterConfig {
  const GpsFilterConfig({
    this.maxAccuracyMeters = 30,
    this.minDistanceMeters = 3,
    this.minInterval = const Duration(seconds: 1),
    this.maxImpliedSpeedMps = 55,
  });

  final double maxAccuracyMeters;
  final double minDistanceMeters;
  final Duration minInterval;
  final double maxImpliedSpeedMps;
}

class GpsFilter {
  const GpsFilter([this.config = const GpsFilterConfig()]);

  final GpsFilterConfig config;

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
