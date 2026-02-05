class DriverLocationModel {
  final double lat;
  final double lng;
  final double heading;
  final double speed;
  final bool isOnline;
  final int? updatedAt;

  const DriverLocationModel({
    required this.lat,
    required this.lng,
    required this.heading,
    required this.speed,
    required this.isOnline,
    required this.updatedAt,
  });

  factory DriverLocationModel.empty() {
    return const DriverLocationModel(
      lat: 0,
      lng: 0,
      heading: 0,
      speed: 0,
      isOnline: false,
      updatedAt: null,
    );
  }

  factory DriverLocationModel.fromMap(Map<dynamic, dynamic> data) {
    return DriverLocationModel(
      lat: (data['lat'] ?? 0).toDouble(),
      lng: (data['lng'] ?? 0).toDouble(),
      heading: (data['heading'] ?? 0).toDouble(),
      speed: (data['speed'] ?? 0).toDouble(),
      isOnline: (data['isOnline'] ?? false) as bool,
      updatedAt: data['updatedAt'] is int ? data['updatedAt'] as int : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'heading': heading,
      'speed': speed,
      'isOnline': isOnline,
      'updatedAt': updatedAt,
    };
  }
}
