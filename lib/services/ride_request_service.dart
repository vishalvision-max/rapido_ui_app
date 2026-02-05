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

  Future<bool> acceptRequest({
    required String requestId,
    required String driverId,
  }) async {
    final result = await requestRef(requestId).runTransaction((current) {
      if (current == null) return Transaction.abort();
      if (current is! Map) return Transaction.abort();
      final Map data = Map.from(current as Map);
      if (data['status'] != 'searching') {
        return Transaction.abort();
      }
      data['status'] = 'accepted';
      data['assignedDriverId'] = driverId;
      data['updatedAt'] = ServerValue.timestamp;
      return Transaction.success(data);
    });
    return result.committed;
  }

  Future<void> rejectRequest({
    required String requestId,
    required String driverId,
  }) async {
    await requestRef(requestId).child('rejectedBy/$driverId').set(true);
  }

  Future<void> cancelRequest(String requestId) async {
    await requestRef(requestId).update({
      'status': 'cancelled',
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> timeoutRequest(String requestId) async {
    await requestRef(requestId).update({
      'status': 'timeout',
      'updatedAt': ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> watchRequest(String requestId) {
    return requestRef(requestId).onValue;
  }
}
