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
    this.polylineSegments = const [],
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
  final List<List<TrackPoint>> polylineSegments;
  final List<Stop> stops;
  final List<domain.Marker> trackMarkers;
  final bool showStartEndMarkers;
  final void Function(MapCamera camera, bool hasGesture)? onCameraChanged;
  final VoidCallback? onMapReady;
  final void Function(LatLng point)? onTap;

  @override
  Widget build(BuildContext context) {
    final segments = polylineSegments.isNotEmpty
        ? polylineSegments
        : (recordingPoints.isEmpty
            ? const <List<TrackPoint>>[]
            : [recordingPoints]);
    final polylineLatLngs = [
      for (final segment in segments)
        [
          for (final point in segment) LatLng(point.latitude, point.longitude),
        ],
    ];
    final startEndPoints = [
      for (final segment in polylineLatLngs)
        ...segment,
    ];

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

        if (polylineLatLngs.any((segment) => segment.length >= 2))
          PolylineLayer(
            polylines: [
              for (final segment in polylineLatLngs)
                if (segment.length >= 2)
                  Polyline(
                    points: segment,
                    strokeWidth: 4,
                    color: Colors.blue,
                  ),
            ],
          ),

        if (showStartEndMarkers && startEndPoints.isNotEmpty)
          MarkerLayer(
            markers: [
              Marker(
                point: startEndPoints.first,
                width: 36,
                height: 36,
                child: const Icon(Icons.flag, color: Colors.green),
              ),
              if (startEndPoints.length > 1)
                Marker(
                  point: startEndPoints.last,
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
