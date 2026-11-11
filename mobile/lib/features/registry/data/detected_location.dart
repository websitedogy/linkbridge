class DetectedLocation {
  const DetectedLocation({
    required this.label,
    this.latitude,
    this.longitude,
  });

  final String label;
  final double? latitude;
  final double? longitude;
}
