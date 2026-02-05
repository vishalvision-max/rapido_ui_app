/// Ride model for the app
class Ride {
  final String id;
  final String pickupLocation;
  final String dropLocation;
  final double distance; // in km
  final double fare;
  final String rideType; // 'bike', 'auto', etc.
  final String
  status; // 'searching', 'accepted', 'ongoing', 'completed', 'cancelled'
  final DateTime? bookingTime;
  final Rider? rider;

  Ride({
    required this.id,
    required this.pickupLocation,
    required this.dropLocation,
    required this.distance,
    required this.fare,
    required this.rideType,
    required this.status,
    this.bookingTime,
    this.rider,
  });

  // Get dummy rides for history
  static List<Ride> getDummyRideHistory() {
    return [
      Ride(
        id: '1',
        pickupLocation: 'MG Road, Bangalore',
        dropLocation: 'Koramangala, Bangalore',
        distance: 5.2,
        fare: 45.0,
        rideType: 'bike',
        status: 'completed',
        bookingTime: DateTime.now().subtract(const Duration(days: 2)),
        rider: Rider(
          id: '101',
          name: 'Rajesh Kumar',
          rating: 4.8,
          vehicleNumber: 'KA 01 AB 1234',
          phone: '+91 9876543211',
          photoUrl: null,
        ),
      ),
      Ride(
        id: '2',
        pickupLocation: 'Indiranagar, Bangalore',
        dropLocation: 'Whitefield, Bangalore',
        distance: 12.5,
        fare: 95.0,
        rideType: 'bike',
        status: 'completed',
        bookingTime: DateTime.now().subtract(const Duration(days: 5)),
        rider: Rider(
          id: '102',
          name: 'Suresh Reddy',
          rating: 4.5,
          vehicleNumber: 'KA 02 CD 5678',
          phone: '+91 9876543212',
          photoUrl: null,
        ),
      ),
      Ride(
        id: '3',
        pickupLocation: 'HSR Layout, Bangalore',
        dropLocation: 'Electronic City, Bangalore',
        distance: 8.3,
        fare: 65.0,
        rideType: 'bike',
        status: 'completed',
        bookingTime: DateTime.now().subtract(const Duration(days: 10)),
        rider: Rider(
          id: '103',
          name: 'Prakash Sharma',
          rating: 4.9,
          vehicleNumber: 'KA 03 EF 9012',
          phone: '+91 9876543213',
          photoUrl: null,
        ),
      ),
    ];
  }
}

/// Rider model
class Rider {
  final String id;
  final String name;
  final double rating;
  final String vehicleNumber;
  final String phone;
  final String? photoUrl;

  Rider({
    required this.id,
    required this.name,
    required this.rating,
    required this.vehicleNumber,
    required this.phone,
    this.photoUrl,
  });

  // Get dummy rider
  static Rider getDummyRider() {
    return Rider(
      id: '101',
      name: 'Rajesh Kumar',
      rating: 4.8,
      vehicleNumber: 'KA 01 AB 1234',
      phone: '+91 9876543211',
      photoUrl: null,
    );
  }
}
