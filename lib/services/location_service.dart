import 'dart:io';

import 'package:geolocator/geolocator.dart';

import '../core/constants.dart';

class LocationService {
  Future<bool> ensurePermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    final bool ok = await ensurePermission();
    if (!ok) return null;

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Stream<Position> getPositionStream() {
    final LocationSettings settings;

    if (Platform.isAndroid) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppConstants.distanceFilterMeters,
        intervalDuration: AppConstants.androidUpdateInterval,
      );
    } else if (Platform.isIOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppConstants.distanceFilterMeters,
        pauseLocationUpdatesAutomatically: true,
        activityType: ActivityType.automotiveNavigation,
      );
    } else {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppConstants.distanceFilterMeters,
      );
    }

    return Geolocator.getPositionStream(locationSettings: settings);
  }
}
