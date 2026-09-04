/// A user-initiated recording pause, used as input to stop detection.
///
/// Domain-only: no Flutter or plugin types.
class PauseInterval {
  const PauseInterval({
    required this.startedAt,
    required this.finishedAt,
    required this.latitude,
    required this.longitude,
  });

  final DateTime startedAt;
  final DateTime finishedAt;
  final double latitude;
  final double longitude;
}
