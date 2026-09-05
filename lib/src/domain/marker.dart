class Marker {
  const Marker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.title,
    required this.description,
  });

  final String id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String title;
  final String description;
}
