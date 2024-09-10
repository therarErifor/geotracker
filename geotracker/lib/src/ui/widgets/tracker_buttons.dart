import 'package:flutter/material.dart';
import 'package:geotracker/src/features/main/preseintation/main_cubit.dart';

class TrackerButtons extends StatefulWidget {
  TrackerButtons(
      {required this.trackingStatus,
      required this.startTracking,
      required this.pauseTracking,
      required this.finishTracking,
      super.key});

  final TrackingStatus trackingStatus;
  final VoidCallback startTracking;
  final VoidCallback pauseTracking;
  final VoidCallback finishTracking;

  @override
  State<TrackerButtons> createState() => _TrackerButtonsState();
}

class _TrackerButtonsState extends State<TrackerButtons> {
  final duration = const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AnimatedSwitcher(
          duration: duration,
          transitionBuilder: (Widget child, Animation<double> animation) =>
              ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: widget.trackingStatus != TrackingStatus.isNotTracking
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible:
                          widget.trackingStatus != TrackingStatus.isNotTracking,
                      child: ElevatedButton(
                          onPressed: widget.pauseTracking,
                          child: const Icon(Icons.pause_rounded)),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Visibility(
                      visible:
                          widget.trackingStatus != TrackingStatus.isNotTracking,
                      child: ElevatedButton(
                          onPressed: widget.finishTracking,
                          child: const Icon(Icons.stop_rounded)),
                    ),
                  ],
                )
              : Visibility(
                  visible:
                      widget.trackingStatus == TrackingStatus.isNotTracking,
                  child: ElevatedButton(
                    onPressed: widget.startTracking,
                    child: const Text('Старт'),
                  ),
                ),
        ),
      );
}
