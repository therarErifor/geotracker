import 'package:flutter_test/flutter_test.dart';
import 'package:geotracker/src/entities/tracking_status.dart';
import 'package:geotracker/src/features/main/preseintation/locate_button_kind.dart';

void main() {
  group('locateButtonKind', () {
    test('hides when there is no user position', () {
      expect(
        locateButtonKind(
          trackingStatus: TrackingStatus.rest,
          cameraLockedToUser: false,
          hasUserPosition: false,
        ),
        LocateButtonKind.hidden,
      );
    });

    test('hides when the camera is locked to the user', () {
      for (final status in TrackingStatus.values) {
        expect(
          locateButtonKind(
            trackingStatus: status,
            cameraLockedToUser: true,
            hasUserPosition: true,
          ),
          LocateButtonKind.hidden,
        );
      }
    });

    test('shows find-me after a pan when not recording', () {
      expect(
        locateButtonKind(
          trackingStatus: TrackingStatus.rest,
          cameraLockedToUser: false,
          hasUserPosition: true,
        ),
        LocateButtonKind.findMe,
      );
      expect(
        locateButtonKind(
          trackingStatus: TrackingStatus.pause,
          cameraLockedToUser: false,
          hasUserPosition: true,
        ),
        LocateButtonKind.findMe,
      );
      expect(
        locateButtonKind(
          trackingStatus: TrackingStatus.finish,
          cameraLockedToUser: false,
          hasUserPosition: true,
        ),
        LocateButtonKind.findMe,
      );
    });

    test('shows follow-user after a pan while recording', () {
      expect(
        locateButtonKind(
          trackingStatus: TrackingStatus.tracking,
          cameraLockedToUser: false,
          hasUserPosition: true,
        ),
        LocateButtonKind.followUser,
      );
    });
  });
}
