import 'package:geolocator/geolocator.dart';

class ProximityChecker {
  /// Ensures location permissions and services are enabled.
  static Future<bool> ensurePermissions() async {
    // Check if location services are enabled
    if (!await Geolocator.isLocationServiceEnabled()) {
      print("❌ Location services are disabled.");
      return false;
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      print("❌ Location permissions denied.");
      return false;
    }

    return true;
  }

  /// Safely get current location. Returns null if location cannot be fetched.
  static Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      print("❌ Failed to get current location: $e");
      return null;
    }
  }

  /// Calculate distance between two coordinates (in meters)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Check if another user is within the given radius from current location
  static Future<bool> isUserInRange({
    required double otherLat,
    required double otherLon,
    double radiusInMeters = 100.0,
  }) async {
    final hasPermission = await ensurePermissions();
    if (!hasPermission) return false;

    final myPos = await getCurrentLocation();
    if (myPos == null) return false;

    final distance = calculateDistance(
      myPos.latitude,
      myPos.longitude,
      otherLat,
      otherLon,
    );

    print("📏 Distance to peer: ${distance.toStringAsFixed(2)} m");
    return distance <= radiusInMeters;
  }

  /// Optional utility: Check proximity if you already have your own location
  static bool isInRangeWithMyLocation({
    required double myLat,
    required double myLon,
    required double otherLat,
    required double otherLon,
    double radiusInMeters = 1000.0,
  }) {
    final distance = calculateDistance(myLat, myLon, otherLat, otherLon);
    print("📏 Pre-fetched distance: ${distance.toStringAsFixed(2)} m");
    return distance <= radiusInMeters;
  }
}
