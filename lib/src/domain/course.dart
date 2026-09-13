import 'package:geotracker/src/domain/track_calculations.dart';
import 'package:geotracker/src/domain/track_point.dart';

class Course {
  Course._();

  static const double minSpeedMps = 0.5;
  static const double restMinDistanceMeters = 8;
  static const double recordingMinDistanceMeters = 3;

  static double? resolveCourseDegrees({
    double? gpsHeading,
    double? speedMps,
    TrackPoint? from,
    TrackPoint? to,
    double minDistanceMeters = restMinDistanceMeters,
    double? previousCourseDegrees,
  }) {
    if (gpsHeading != null &&
        gpsHeading >= 0 &&
        speedMps != null &&
        speedMps >= minSpeedMps) {
      return gpsHeading % 360;
    }
    if (from != null && to != null) {
      final distance = TrackCalculations.distanceBetween(from, to);
      if (distance >= minDistanceMeters) {
        return TrackCalculations.bearingDegrees(from, to);
      }
    }
    return previousCourseDegrees;
  }
}
