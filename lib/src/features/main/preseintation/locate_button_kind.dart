import 'package:geotracker/src/entities/tracking_status.dart';

enum LocateButtonKind { hidden, findMe, followUser }

LocateButtonKind locateButtonKind({
  required TrackingStatus trackingStatus,
  required bool cameraLockedToUser,
  required bool hasUserPosition,
}) {
  if (!hasUserPosition || cameraLockedToUser) {
    return LocateButtonKind.hidden;
  }
  if (trackingStatus == TrackingStatus.tracking) {
    return LocateButtonKind.followUser;
  }
  return LocateButtonKind.findMe;
}
