import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';

class RideRequestService {
  final DatabaseReference _requestsRef =
      FirebaseDatabase.instance.ref('rideRequests');

  DatabaseReference requestRef(String requestId) => _requestsRef.child(requestId);

  Future<String> createRideRequest({
    required String riderId,
    required String pickupText,
    required String dropText,
    required LatLng pickup,
    required LatLng drop,
    required String rideType,
    required double fare,
  }) async {
    final DatabaseReference ref = _requestsRef.push();
    await ref.set({
      'riderId': riderId,
      'pickupText': pickupText,
      'dropText': dropText,
      'pickupLat': pickup.latitude,
      'pickupLng': pickup.longitude,
      'dropLat': drop.latitude,
      'dropLng': drop.longitude,
      'rideType': rideType,
      'fare': fare,
      'status': 'searching',
      'assignedDriverId': null,
      'createdAt': ServerValue.timestamp,
    });
    return ref.key!;
  }

  Future<void> updateStatus({
    required String requestId,
    required String status,
    String? assignedDriverId,
  }) async {
    await requestRef(requestId).update({
      'status': status,
      if (assignedDriverId != null) 'assignedDriverId': assignedDriverId,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> watchRequest(String requestId) {
    return requestRef(requestId).onValue;
  }
}
