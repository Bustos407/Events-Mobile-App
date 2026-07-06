import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Falls back to Mexico City coordinates when location is unavailable
  /// (emulator without GPS, permission denied, etc.).
  static const _fallbackLat = 19.4326;
  static const _fallbackLng = -99.1332;

  Future<(double, double)> getCurrentLatLng() async {
    try {
      final permission = await Geolocator.checkPermission();
      var granted = permission;
      if (granted == LocationPermission.denied) {
        granted = await Geolocator.requestPermission();
      }
      if (granted == LocationPermission.denied ||
          granted == LocationPermission.deniedForever) {
        return (_fallbackLat, _fallbackLng);
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return (_fallbackLat, _fallbackLng);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      ).timeout(const Duration(seconds: 8));
      return (position.latitude, position.longitude);
    } catch (_) {
      return (_fallbackLat, _fallbackLng);
    }
  }

  double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }
}
