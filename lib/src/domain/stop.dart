class Stop {
  const Stop({
    required this.startedAt,
    required this.finishedAt,
    required this.duration,
    required this.latitude,
    required this.longitude,
  });

  final DateTime startedAt;
  final DateTime finishedAt;
  final Duration duration;
  final double latitude;
  final double longitude;
}
