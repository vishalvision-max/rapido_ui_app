import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/colors.dart';
import '../../services/ride_request_service.dart';
import '../../core/constants.dart';

class SearchingRiderController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late String pickup;
  late String drop;
  late String rideType;
  late double fare;
  late LatLng pickupLatLng;
  late LatLng dropLatLng;

  late AnimationController pulseController;
  final MapController mapController = MapController();
  final RxList<Marker> markers = <Marker>[].obs;
  final RxList<LatLng> driverPoints = <LatLng>[].obs;
  final RideRequestService _rideRequestService = RideRequestService();
  final DatabaseReference _driversRef = FirebaseDatabase.instance.ref(
    AppConstants.driversPath,
  );
  StreamSubscription<DatabaseEvent>? _driversSub;
  StreamSubscription<DatabaseEvent>? _requestSub;
  StreamSubscription<User?>? _authSub;
  String? _requestId;
  static const double _nearbyRadiusMeters = 3000;
  Timer? _searchTimeout;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments ?? <String, dynamic>{}) as Map<String, dynamic>;
    pickup = (args['pickup'] ?? 'Current Location').toString();
    drop = (args['drop'] ?? '').toString();
    rideType = (args['rideType'] ?? 'bike').toString();
    fare = (args['fare'] ?? 0.0).toDouble();
    pickupLatLng = LatLng(
      (args['pickupLat'] ?? 0.0).toDouble(),
      (args['pickupLng'] ?? 0.0).toDouble(),
    );
    dropLatLng = LatLng(
      (args['dropLat'] ?? 0.0).toDouble(),
      (args['dropLng'] ?? 0.0).toDouble(),
    );

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    pulseController.repeat();

    _createRideRequest();
    _updateMarkers();
    _startSearchTimeout();
    _bindAuth();
  }

  Future<void> _createRideRequest() async {
    final String riderId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    _requestId = await _rideRequestService.createRideRequest(
      riderId: riderId,
      pickupText: pickup,
      dropText: drop,
      pickup: pickupLatLng,
      drop: dropLatLng,
      rideType: rideType,
      fare: fare,
    );

    _requestSub = _rideRequestService.watchRequest(_requestId!).listen((event) {
      final Object? data = event.snapshot.value;
      if (data is Map<dynamic, dynamic>) {
        final String status = (data['status'] ?? '').toString();
        if (status == 'accepted') {
          _searchTimeout?.cancel();
          final String driverId = (data['assignedDriverId'] ?? '').toString();
          Get.offNamed(
            '/ride-details',
            arguments: {
              'pickup': pickup,
              'drop': drop,
              'rideType': rideType,
              'fare': fare,
              'pickupLat': pickupLatLng.latitude,
              'pickupLng': pickupLatLng.longitude,
              'dropLat': dropLatLng.latitude,
              'dropLng': dropLatLng.longitude,
              'requestId': _requestId,
              'driverId': driverId,
            },
          );
        } else if (status == 'cancelled' || status == 'timeout') {
          _searchTimeout?.cancel();
          Get.back();
        }
      }
    });
  }

  void _startSearchTimeout() {
    _searchTimeout?.cancel();
    _searchTimeout = Timer(const Duration(seconds: 45), () async {
      if (_requestId == null) return;
      await _rideRequestService.timeoutRequest(_requestId!);
      Get.snackbar(
        'No captains found',
        'Please try again',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      Get.back();
    });
  }

  void _startDriverListener() {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    _driversSub?.cancel();
    _driversSub = _driversRef
        .orderByChild('isOnline')
        .equalTo(true)
        .onValue
        .listen((event) {
          final Object? data = event.snapshot.value;
          final List<LatLng> points = [];
          if (data is Map<dynamic, dynamic>) {
            data.forEach((_, value) {
              if (value is Map<dynamic, dynamic>) {
                final double lat = (value['lat'] ?? 0).toDouble();
                final double lng = (value['lng'] ?? 0).toDouble();
                final double distance = Geolocator.distanceBetween(
                  pickupLatLng.latitude,
                  pickupLatLng.longitude,
                  lat,
                  lng,
                );
                if (distance <= _nearbyRadiusMeters) {
                  points.add(LatLng(lat, lng));
                }
              }
            });
          }
          driverPoints.assignAll(points);
          _updateMarkers();
        });
  }

  void _bindAuth() {
    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _driversSub?.cancel();
        _driversSub = null;
        driverPoints.clear();
        _updateMarkers();
      } else {
        _startDriverListener();
      }
    });
    if (FirebaseAuth.instance.currentUser != null) {
      _startDriverListener();
    }
  }

  void _updateMarkers() {
    final List<Marker> nextMarkers = [
      Marker(
        point: pickupLatLng,
        width: 44,
        height: 44,
        child: const Icon(
          Icons.my_location,
          color: AppColors.success,
          size: 30,
        ),
      ),
      Marker(
        point: dropLatLng,
        width: 44,
        height: 44,
        child: const Icon(Icons.location_on, color: AppColors.error, size: 32),
      ),
    ];

    for (final point in driverPoints) {
      nextMarkers.add(
        Marker(
          point: point,
          width: 40,
          height: 40,
          child: const Icon(Icons.navigation, color: Colors.green, size: 28),
        ),
      );
    }

    markers.assignAll(nextMarkers);
  }

  @override
  void onClose() {
    pulseController.dispose();
    _driversSub?.cancel();
    _requestSub?.cancel();
    _searchTimeout?.cancel();
    _authSub?.cancel();
    super.onClose();
  }
}

class SearchingRiderScreen extends StatelessWidget {
  const SearchingRiderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchingRiderController());

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Stack(
        children: [
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: controller.pickupLatLng,
              initialZoom: 14,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.rapido.ui',
              ),
              Obx(() => MarkerLayer(markers: controller.markers.toList())),
            ],
          ),
          Container(color: AppColors.primaryBlack.withValues(alpha: 0.35)),
          // Radar Background
          Center(
            child: AnimatedBuilder(
              animation: controller.pulseController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildPulseCircle(controller.pulseController.value, 300),
                    _buildPulseCircle(controller.pulseController.value, 200),
                    _buildPulseCircle(controller.pulseController.value, 100),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryYellow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getRideIcon(controller.rideType),
                        size: 50,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Top Info
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: FadeInDown(
              child: Column(
                children: [
                  const Text(
                    'Finding your Captain',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Matching you with nearest riders...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Card
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: FadeInUp(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                controller.drop,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '₹${controller.fare}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 30),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Verified Captains only',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              controller.rideType.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: TextButton(
                      onPressed: () async {
                        if (controller._requestId != null) {
                          await controller._rideRequestService.cancelRequest(
                            controller._requestId!,
                          );
                        }
                        Get.back();
                      },
                      child: const Text(
                        'Cancel Ride',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseCircle(double value, double size) {
    return Container(
      width: size * (1 + value),
      height: size * (1 + value),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryYellow.withValues(alpha: 1 - value),
          width: 2,
        ),
      ),
    );
  }

  IconData _getRideIcon(String type) {
    switch (type) {
      case 'auto':
        return Icons.airport_shuttle;
      case 'cab':
        return Icons.local_taxi;
      default:
        return Icons.two_wheeler;
    }
  }
}
