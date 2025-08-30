import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../entities/user_position.dart';

const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

class Map extends StatelessWidget {
  const Map({
    super.key,
    required this.options,
    required this.controller,
    this.userPosition,
  });

  final MapOptions options;
  final MapController controller;
  final UserPosition? userPosition;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: options,
      children: [
        TileLayer(urlTemplate: urlTemplate),

        if (userPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: userPosition!.currentPosition,
                child: Transform.rotate(
                  angle: userPosition!.heading * (3.14159265 / 180),
                  child: Icon(Icons.navigation, color: Colors.red),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
