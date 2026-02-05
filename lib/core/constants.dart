import 'package:latlong2/latlong.dart';

class AppConstants {
  static const String driversPath = 'drivers';

  // Location update settings
  static const int distanceFilterMeters = 10;
  static const Duration androidUpdateInterval = Duration(seconds: 5);
  static const Duration iosUpdateInterval = Duration(seconds: 5);

  // Map defaults
  static const LatLng defaultMapCenter = LatLng(28.6139, 77.2090); // Delhi
  static const double defaultZoom = 15.0;
}
