import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

class Map extends StatelessWidget {

  const Map({super.key, required this.options, required this.controller});

  final MapOptions options;
  final MapController controller;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: options, 
      children: [
      TileLayer(
        urlTemplate: urlTemplate,
      )
    ]);
  }
}