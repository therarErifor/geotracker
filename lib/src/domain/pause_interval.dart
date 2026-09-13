class PauseInterval {
  const PauseInterval({
    required this.startedAt,
    required this.finishedAt,
    required this.latitude,
    required this.longitude,
    this.pointCountAtStart,
  });

  final DateTime startedAt;
  final DateTime finishedAt;
  final double latitude;
  final double longitude;
  final int? pointCountAtStart;
}
