import 'package:flutter/material.dart';

import '../../entities/tracking_status.dart';

class TrackingButtons extends StatelessWidget {
  const TrackingButtons({super.key,
    required this.trackingStatus,
    required this.tracking,
    required this.pauseTracking,
    required this.finishTracking,
    required this.saveTrack,
    required this.deleteTrack,
  });
  final TrackingStatus trackingStatus;
  final VoidCallback tracking;
  final VoidCallback pauseTracking;
  final VoidCallback finishTracking;
  final VoidCallback saveTrack;
  final VoidCallback deleteTrack;

  @override
  Widget build(BuildContext context) {
    return switch (trackingStatus) {
      TrackingStatus.rest => ElevatedButton(
        onPressed: () => tracking(),
        child: const Text('Старт'),
      ),

      TrackingStatus.tracking => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => pauseTracking(),
            child: const Text('Пауза'),
          ),
          SizedBox(width: 30),
          ElevatedButton(
            onPressed: () => finishTracking(),
            child: const Text('Финиш'),
          ),
        ],
      ),

      TrackingStatus.pause => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => tracking(),
            child: const Text('Продолжить'),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            onPressed: () => finishTracking(),
            child: const Text('Финиш'),
          ),
        ],
      ),

      TrackingStatus.finish => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => saveTrack(),
            child: const Text('Сохранить маршрут'),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            onPressed: () => deleteTrack(),
            child: const Text('Удалить маршрут'),
          ),
        ],
      ),
    };
  }
}
