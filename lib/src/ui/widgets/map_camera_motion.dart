import 'package:flutter/animation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const Duration mapCameraAnimationDuration = Duration(milliseconds: 250);
const Curve mapCameraAnimationCurve = Curves.easeOutCubic;

void moveMapCamera(
  MapController controller,
  LatLng center,
  double zoom, {
  bool animated = true,
  Duration duration = mapCameraAnimationDuration,
  Curve curve = mapCameraAnimationCurve,
}) {
  if (!animated) {
    controller.move(center, zoom);
    return;
  }

  final impl = controller as MapControllerImpl;
  if (impl.camera.center == center && impl.camera.zoom == zoom) {
    return;
  }

  impl.moveAnimatedRaw(
    center,
    zoom,
    duration: duration,
    curve: curve,
    hasGesture: false,
    source: MapEventSource.mapController,
  );
}
