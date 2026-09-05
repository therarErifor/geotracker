import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geotracker/src/domain/marker.dart' as domain;
import 'package:geotracker/src/domain/stop.dart';
import 'package:geotracker/src/domain/track_point.dart';
import 'package:latlong2/latlong.dart';

import '../../entities/user_position.dart';

const urlTemplate =
    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
const tileUserAgentPackageName = 'com.example.geotracker';

class Map extends StatelessWidget {
  const Map({
    super.key,
    required this.controller,
    required this.initialCenter,
    required this.initialZoom,
    this.userPosition,
    this.recordingPoints = const [],
    this.stops = const [],
    this.trackMarkers = const [],
    this.showStartEndMarkers = false,
    this.onCameraChanged,
    this.onMapReady,
    this.onTap,
  });

  final MapController controller;
  final LatLng initialCenter;
  final double initialZoom;
  final UserPosition? userPosition;
  final List<TrackPoint> recordingPoints;
  final List<Stop> stops;
  final List<domain.Marker> trackMarkers;
  final bool showStartEndMarkers;
  final void Function(MapCamera camera, bool hasGesture)? onCameraChanged;
  final VoidCallback? onMapReady;
  final void Function(LatLng point)? onTap;

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
        onTap: onTap == null
            ? null
            : (tapPosition, point) => onTap!(point),
        onPositionChanged: (camera, hasGesture) {
          onCameraChanged?.call(camera, hasGesture);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: urlTemplate,
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: tileUserAgentPackageName,
        ),
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap, CARTO'),
        ),

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

        if (stops.isNotEmpty)
          MarkerLayer(
            markers: [
              for (final stop in stops)
                Marker(
                  point: LatLng(stop.latitude, stop.longitude),
                  width: 32,
                  height: 32,
                  child: const Icon(Icons.pause_circle, color: Colors.orange),
                ),
            ],
          ),

        if (trackMarkers.isNotEmpty)
          MarkerLayer(
            markers: [
              for (final marker in trackMarkers)
                Marker(
                  point: LatLng(marker.latitude, marker.longitude),
                  width: 36,
                  height: 36,
                  child: Tooltip(
                    message: marker.title,
                    child: const Icon(Icons.place, color: Colors.deepPurple),
                  ),
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
