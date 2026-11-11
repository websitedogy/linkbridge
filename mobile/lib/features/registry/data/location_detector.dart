import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'detected_location.dart';

class LocationDetector {
  Future<DetectedLocation> detect() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationDetectException(
        'Turn on location services to detect your current location.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationDetectException(
        'Location permission is needed to fill your current location.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationDetectException(
        'Location is blocked. Enable it in settings and try again.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 12),
      ),
    );

    try {
      final marks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final mark = marks.isEmpty ? null : marks.first;
      final label = _label(mark);
      if (label.isNotEmpty) {
        return DetectedLocation(
          label: label,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (_) {}

    return DetectedLocation(
      label:
          '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  String _label(Placemark? mark) {
    if (mark == null) {
      return '';
    }
    final parts = [
      _clean(mark.subLocality),
      _clean(mark.locality),
      _clean(mark.administrativeArea),
      _clean(mark.postalCode),
      _clean(mark.country),
    ].whereType<String>().toList();
    return parts.join(', ');
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

class LocationDetectException implements Exception {
  const LocationDetectException(this.message);

  final String message;

  @override
  String toString() => message;
}
