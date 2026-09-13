class GeoFix {
  const GeoFix({
    required this.latitude,
    required this.longitude,
    this.speedMps,
    this.courseDegrees,
  });

  final double latitude;
  final double longitude;
  final double? speedMps;
  final double? courseDegrees;
}
