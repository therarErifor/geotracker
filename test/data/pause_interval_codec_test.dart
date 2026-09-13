import 'package:flutter_test/flutter_test.dart';
import 'package:geotracker/src/data/mappers/pause_interval_codec.dart';
import 'package:geotracker/src/domain/pause_interval.dart';

void main() {
  const codec = PauseIntervalCodec();

  test('round-trips pause intervals and open pause meta', () {
    final startedAt = DateTime.utc(2026, 9, 4, 10);
    final finishedAt = startedAt.add(const Duration(minutes: 2));
    final openPause = DateTime.utc(2026, 9, 4, 11);

    final encoded = codec.encode(
      intervals: [
        PauseInterval(
          startedAt: startedAt,
          finishedAt: finishedAt,
          latitude: 55.75,
          longitude: 37.62,
          pointCountAtStart: 1,
        ),
      ],
      totalPausedDuration: const Duration(minutes: 2),
      openPauseStartedAt: openPause,
    );

    final decoded = codec.decode(encoded);
    expect(decoded.intervals, hasLength(1));
    expect(decoded.intervals.first.latitude, 55.75);
    expect(decoded.intervals.first.pointCountAtStart, 1);
    expect(decoded.totalPausedDuration, const Duration(minutes: 2));
    expect(decoded.openPauseStartedAt, openPause);
  });

  test('decode without pointCountAtStart keeps it null', () {
    final startedAt = DateTime.utc(2026, 9, 4, 10);
    final encoded = codec.encode(
      intervals: [
        PauseInterval(
          startedAt: startedAt,
          finishedAt: startedAt.add(const Duration(minutes: 2)),
          latitude: 55.75,
          longitude: 37.62,
        ),
      ],
      totalPausedDuration: Duration.zero,
    );
    final decoded = codec.decode(encoded);
    expect(decoded.intervals.first.pointCountAtStart, isNull);
  });
}
