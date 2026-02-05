import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants.dart';
import '../models/driver_location_model.dart';

class FirebaseLocationService {
  final DatabaseReference _driversRef =
      FirebaseDatabase.instance.ref(AppConstants.driversPath);

  DatabaseReference driverRef(String driverId) => _driversRef.child(driverId);

  Future<void> setDriverOnline(String driverId, bool isOnline) async {
    debugPrint('RTDB: setDriverOnline drivers/$driverId isOnline=$isOnline');
    await driverRef(driverId).update({
      'isOnline': isOnline,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> updateDriverLocation({
    required String driverId,
    required Position position,
    required bool isOnline,
  }) async {
    debugPrint('RTDB: updateDriverLocation drivers/$driverId');
    await driverRef(driverId).update({
      'lat': position.latitude,
      'lng': position.longitude,
      'heading': position.heading,
      'speed': position.speed,
      'isOnline': isOnline,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Stream<DriverLocationModel?> watchDriverLocation(String driverId) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Stream<DriverLocationModel?>.empty();
    }
    debugPrint('RTDB: watchDriverLocation drivers/$driverId');
    return driverRef(driverId).onValue.map((event) {
      final Object? data = event.snapshot.value;
      if (data is Map<dynamic, dynamic>) {
        return DriverLocationModel.fromMap(data);
      }
      return null;
    });
  }
}
