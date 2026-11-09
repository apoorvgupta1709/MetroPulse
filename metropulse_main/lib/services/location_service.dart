import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/station.dart';

class StationDistance {
  final Station station;
  final double distanceKm;

  StationDistance({required this.station, required this.distanceKm});
}

class LocationService {
  /// Request GPS permission and fetch current user position
  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 6),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Calculates nearest stations sorted by distance
  static List<StationDistance> findNearestStations({
    required double userLat,
    required double userLng,
    required List<Station> stations,
  }) {
    final list = stations.map((station) {
      final dist = _haversineDistance(
        userLat,
        userLng,
        station.latitude,
        station.longitude,
      );
      return StationDistance(station: station, distanceKm: dist);
    }).toList();

    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
