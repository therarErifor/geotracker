import 'package:latlong2/latlong.dart';

class UserPosition {
  late LatLng currentPosition;
  late double? heading;
  late double? speed;

  UserPosition({
    required this.currentPosition,
    this.heading,
    this.speed,
  });
}
