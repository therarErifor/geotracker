import 'package:flutter_test/flutter_test.dart';
import 'package:geotracker/src/domain/session_elapsed.dart';

void main() {
  final startedAt = DateTime.utc(2026, 1, 1, 12);

  group('SessionElapsed.compute', () {
    test('returns zero when idle or startedAt is null', () {
      final now = startedAt.add(const Duration(minutes: 5));
      expect(
        SessionElapsed.compute(now: now, isIdle: true, isPaused: false, isFinished: false),
        Duration.zero,
      );
      expect(
        SessionElapsed.compute(
          now: now,
          isIdle: false,
          isPaused: false,
          isFinished: false,
        ),
        Duration.zero,
      );
    });

    test('returns elapsed time while recording', () {
      final now = startedAt.add(const Duration(minutes: 10));
      expect(
        SessionElapsed.compute(
          startedAt: startedAt,
          now: now,
          isIdle: false,
          isPaused: false,
          isFinished: false,
        ),
        const Duration(minutes: 10),
      );
    });

    test('subtracts completed pause duration while recording', () {
      final now = startedAt.add(const Duration(minutes: 10));
      expect(
        SessionElapsed.compute(
          startedAt: startedAt,
          totalPausedDuration: const Duration(minutes: 3),
          now: now,
          isIdle: false,
          isPaused: false,
          isFinished: false,
        ),
        const Duration(minutes: 7),
      );
    });

    test('freezes elapsed at pauseStartedAt', () {
      final pauseStartedAt = startedAt.add(const Duration(minutes: 4));
      final now = pauseStartedAt.add(const Duration(minutes: 5));
      expect(
        SessionElapsed.compute(
          startedAt: startedAt,
          pauseStartedAt: pauseStartedAt,
          now: now,
          isIdle: false,
          isPaused: true,
          isFinished: false,
        ),
        const Duration(minutes: 4),
      );
    });

    test('freezes elapsed at finishedAt', () {
      final finishedAt = startedAt.add(const Duration(minutes: 8));
      final now = finishedAt.add(const Duration(hours: 1));
      expect(
        SessionElapsed.compute(
          startedAt: startedAt,
          finishedAt: finishedAt,
          now: now,
          isIdle: false,
          isPaused: false,
          isFinished: true,
        ),
        const Duration(minutes: 8),
      );
    });

    test('accounts for pauses before finish', () {
      final finishedAt = startedAt.add(const Duration(minutes: 15));
      expect(
        SessionElapsed.compute(
          startedAt: startedAt,
          totalPausedDuration: const Duration(minutes: 5),
          finishedAt: finishedAt,
          now: finishedAt,
          isIdle: false,
          isPaused: false,
          isFinished: true,
        ),
        const Duration(minutes: 10),
      );
    });
  });
}
