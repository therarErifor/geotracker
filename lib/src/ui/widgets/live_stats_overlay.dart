import 'package:flutter/material.dart';
import 'package:geotracker/src/ui/formatters/track_formatters.dart';

class LiveStatsOverlay extends StatelessWidget {
  const LiveStatsOverlay({
    super.key,
    required this.distanceMeters,
    required this.elapsedTime,
    required this.currentSpeedKmh,
    required this.averageSpeedKmh,
  });

  final double distanceMeters;
  final Duration elapsedTime;
  final double? currentSpeedKmh;
  final double averageSpeedKmh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface.withValues(alpha: 0.92),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatItem(
              label: 'Дистанция',
              value: TrackFormatters.formatDistanceKm(distanceMeters),
            ),
            const SizedBox(width: 16),
            _StatItem(
              label: 'Время',
              value: TrackFormatters.formatDurationHms(elapsedTime),
            ),
            const SizedBox(width: 16),
            _StatItem(
              label: 'Сейчас',
              value: TrackFormatters.formatSpeedKmh(currentSpeedKmh),
            ),
            const SizedBox(width: 16),
            _StatItem(
              label: 'Средняя',
              value: TrackFormatters.formatSpeedKmh(averageSpeedKmh),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
