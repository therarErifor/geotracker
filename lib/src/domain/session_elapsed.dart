class SessionElapsed {
  SessionElapsed._();

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
