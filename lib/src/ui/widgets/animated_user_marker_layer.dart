import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geotracker/src/entities/user_position.dart';
import 'package:latlong2/latlong.dart';

import 'map_camera_motion.dart';

class AnimatedUserMarkerLayer extends StatefulWidget {
  const AnimatedUserMarkerLayer({
    super.key,
    required this.userPosition,
    this.animatePosition = false,
    this.animationDuration = mapGpsFollowAnimationDuration,
  });

  final UserPosition userPosition;
  final bool animatePosition;
  final Duration animationDuration;

  @override
  State<AnimatedUserMarkerLayer> createState() => _AnimatedUserMarkerLayerState();
}

class _AnimatedUserMarkerLayerState extends State<AnimatedUserMarkerLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  LatLng? _from;
  LatLng? _to;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _controller.addListener(() => setState(() {}));
    _to = widget.userPosition.currentPosition;
    _from = _to;
  }

  @override
  void didUpdateWidget(AnimatedUserMarkerLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationDuration != oldWidget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }

    final next = widget.userPosition.currentPosition;
    if (_to == null) {
      _from = next;
      _to = next;
      return;
    }
    if (next == _to) {
      return;
    }

    if (!widget.animatePosition) {
      _from = next;
      _to = next;
      _controller.value = 1;
      return;
    }

    _from = _interpolatedPosition();
    _to = next;
    _controller.forward(from: 0);
  }

  LatLng _interpolatedPosition() {
    if (_from == null || _to == null) {
      return _to ?? _from ?? widget.userPosition.currentPosition;
    }
    if (_from == _to || _controller.value >= 1) {
      return _to!;
    }
    final t = _controller.value;
    return LatLng(
      _from!.latitude + (_to!.latitude - _from!.latitude) * t,
      _from!.longitude + (_to!.longitude - _from!.longitude) * t,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: _interpolatedPosition(),
          child: widget.userPosition.heading == null
              ? const Icon(Icons.my_location, color: Colors.red)
              : Transform.rotate(
                  angle:
                      (widget.userPosition.heading! - 45) * (3.14159265 / 180),
                  child: const Icon(Icons.navigation, color: Colors.red),
                ),
        ),
      ],
    );
  }
}
