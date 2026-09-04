import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/track.dart';

/// Persisted in-progress recording session (kill recovery).
///
/// Domain-only: no Flutter or plugin types.
class RecordingDraft {
  const RecordingDraft({
    required this.track,
    required this.recordingStatus,
    this.pauseIntervals = const [],
    this.totalPausedDuration = Duration.zero,
    this.openPauseStartedAt,
  });

  final Track track;

  /// One of: recording, paused, finished.
  final String recordingStatus;

  final List<PauseInterval> pauseIntervals;
  final Duration totalPausedDuration;
  final DateTime? openPauseStartedAt;
}
