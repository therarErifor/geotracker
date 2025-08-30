import 'package:latlong2/latlong.dart';

class UserPosition {
  late LatLng currentPosition;
  late double heading;
  late double? speed;

  UserPosition({
    required this.currentPosition,
    required this.heading,
    this.speed,
  });
}
