/// Pure wall-clock elapsed time for a recording session, excluding pauses.
class SessionElapsed {
  SessionElapsed._();

  /// Elapsed active time from [startedAt] to the effective end moment.
  ///
  /// - [isIdle] or null [startedAt] → zero.
  /// - Active recording → [now] minus completed pauses ([totalPausedDuration]).
  /// - Paused → frozen at [pauseStartedAt] (current pause not in [totalPausedDuration] yet).
  /// - Finished → frozen at [finishedAt].
  static Duration compute({
    DateTime? startedAt,
    Duration totalPausedDuration = Duration.zero,
    DateTime? pauseStartedAt,
    DateTime? finishedAt,
    required DateTime now,
    required bool isIdle,
    required bool isPaused,
    required bool isFinished,
  }) {
    if (isIdle || startedAt == null) {
      return Duration.zero;
    }

    final DateTime endTime;
    if (isFinished) {
      endTime = finishedAt ?? now;
    } else if (isPaused) {
      endTime = pauseStartedAt ?? now;
    } else {
      endTime = now;
    }

    final elapsed = endTime.difference(startedAt) - totalPausedDuration;
    if (elapsed.isNegative) {
      return Duration.zero;
    }
    return elapsed;
  }
}
