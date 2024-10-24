import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

class Map extends StatelessWidget {

  const Map({super.key, required this.options, required this.controller, this.points, this.userPoint});

  final MapOptions options;
  final MapController controller;
  final List<LatLng>? points;
  final Widget? userPoint;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: options, 
      children: [
      TileLayer(
        urlTemplate: urlTemplate,
      ),
      points != null ? PolylineLayer(
        polylines: [
          Polyline(
            points: points!,
            strokeWidth: 6.0,
            color: Colors.blue
          )
        ]
      )
      : const SizedBox(),
      userPoint ?? const SizedBox()
    ]);
  }
}