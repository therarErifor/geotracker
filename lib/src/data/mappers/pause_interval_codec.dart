import 'dart:convert';

import 'package:geotracker/src/domain/pause_interval.dart';

/// JSON codec for draft pause metadata stored on the tracks row.
class PauseIntervalCodec {
  const PauseIntervalCodec();

  String encode({
    required List<PauseInterval> intervals,
    required Duration totalPausedDuration,
    DateTime? openPauseStartedAt,
  }) {
    return jsonEncode({
      'totalPausedMs': totalPausedDuration.inMilliseconds,
      'openPauseStartedAt': openPauseStartedAt?.toIso8601String(),
      'intervals': [
        for (final interval in intervals)
          {
            'startedAt': interval.startedAt.toIso8601String(),
            'finishedAt': interval.finishedAt.toIso8601String(),
            'latitude': interval.latitude,
            'longitude': interval.longitude,
          },
      ],
    });
  }

  ({
    List<PauseInterval> intervals,
    Duration totalPausedDuration,
    DateTime? openPauseStartedAt,
  }) decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return (
        intervals: const <PauseInterval>[],
        totalPausedDuration: Duration.zero,
        openPauseStartedAt: null,
      );
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return (
        intervals: const <PauseInterval>[],
        totalPausedDuration: Duration.zero,
        openPauseStartedAt: null,
      );
    }

    final intervalsRaw = decoded['intervals'];
    final intervals = <PauseInterval>[];
    if (intervalsRaw is List) {
      for (final item in intervalsRaw) {
        if (item is! Map) {
          continue;
        }
        final map = Map<String, dynamic>.from(item);
        final startedAt = DateTime.tryParse('${map['startedAt']}');
        final finishedAt = DateTime.tryParse('${map['finishedAt']}');
        final latitude = (map['latitude'] as num?)?.toDouble();
        final longitude = (map['longitude'] as num?)?.toDouble();
        if (startedAt == null ||
            finishedAt == null ||
            latitude == null ||
            longitude == null) {
          continue;
        }
        intervals.add(
          PauseInterval(
            startedAt: startedAt,
            finishedAt: finishedAt,
            latitude: latitude,
            longitude: longitude,
          ),
        );
      }
    }

    final totalPausedMs = (decoded['totalPausedMs'] as num?)?.toInt() ?? 0;
    final openRaw = decoded['openPauseStartedAt'];
    final openPauseStartedAt = openRaw is String
        ? DateTime.tryParse(openRaw)
        : null;

    return (
      intervals: intervals,
      totalPausedDuration: Duration(milliseconds: totalPausedMs),
      openPauseStartedAt: openPauseStartedAt,
    );
  }
}
