import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geotracker/src/domain/track_point.dart';
import 'package:latlong2/latlong.dart';

import '../../entities/user_position.dart';

const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

class Map extends StatelessWidget {
  const Map({
    super.key,
    required this.controller,
    required this.initialCenter,
    required this.initialZoom,
    this.userPosition,
    this.recordingPoints = const [],
    this.showStartEndMarkers = false,
    this.onCameraChanged,
    this.onMapReady,
  });

  final MapController controller;
  final LatLng initialCenter;
  final double initialZoom;
  final UserPosition? userPosition;
  final List<TrackPoint> recordingPoints;
  final bool showStartEndMarkers;
  final void Function(MapCamera camera, bool hasGesture)? onCameraChanged;
  final VoidCallback? onMapReady;

  @override
  Widget build(BuildContext context) {
    final polylinePoints = recordingPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        onMapReady: onMapReady,
        onPositionChanged: (camera, hasGesture) {
          onCameraChanged?.call(camera, hasGesture);
        },
      ),
      children: [
        TileLayer(urlTemplate: urlTemplate),

        if (polylinePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: polylinePoints,
                strokeWidth: 4,
                color: Colors.blue,
              ),
            ],
          ),

        if (showStartEndMarkers && polylinePoints.isNotEmpty)
          MarkerLayer(
            markers: [
              Marker(
                point: polylinePoints.first,
                width: 36,
                height: 36,
                child: const Icon(Icons.flag, color: Colors.green),
              ),
              if (polylinePoints.length > 1)
                Marker(
                  point: polylinePoints.last,
                  width: 36,
                  height: 36,
                  child: const Icon(Icons.sports_score, color: Colors.red),
                ),
            ],
          ),

        if (userPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: userPosition!.currentPosition,
                child: Transform.rotate(
                  angle: userPosition!.heading * (3.14159265 / 180),
                  child: const Icon(Icons.navigation, color: Colors.red),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
