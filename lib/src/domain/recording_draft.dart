import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/track.dart';

class RecordingDraft {
  const RecordingDraft({
    required this.track,
    required this.recordingStatus,
    this.pauseIntervals = const [],
    this.totalPausedDuration = Duration.zero,
    this.openPauseStartedAt,
  });

  final Track track;
  final String recordingStatus;
  final List<PauseInterval> pauseIntervals;
  final Duration totalPausedDuration;
  final DateTime? openPauseStartedAt;
}
