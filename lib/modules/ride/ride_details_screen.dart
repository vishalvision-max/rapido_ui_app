import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/colors.dart';
import '../../core/models/ride.dart';
import '../../core/constants.dart';
import '../../services/route_service.dart';
import 'chat_screen.dart';

class RideDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late String pickup;
  late String drop;
  late String rideType;
  late double fare;
  late Rider rider;
  final RxString rideStatus = 'accepted'.obs;
  late LatLng pickupLatLng;
  late LatLng dropLatLng;
  String? requestId;
  String? driverId;

  final MapController mapController = MapController();
  final RxList<Marker> markers = <Marker>[].obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool showGuardianAlert = false.obs;
  final RxBool isSafe = true.obs;

  StreamSubscription<DatabaseEvent>? _requestSub;
  StreamSubscription<DatabaseEvent>? _driverSub;
  final DatabaseReference _requestsRef =
      FirebaseDatabase.instance.ref('rideRequests');
  final DatabaseReference _driversRef =
      FirebaseDatabase.instance.ref(AppConstants.driversPath);
  final RouteService _routeService = RouteService();
  LatLng? _driverPosition;

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
    requestId = args['requestId']?.toString();
    driverId = args['driverId']?.toString();
    rider = Rider.getDummyRider();

    _updateMarkers();
    _watchRideRequest();
    _watchDriverLocation();
    _buildRoute();
  }

  void _watchRideRequest() {
    if (requestId == null) return;
    _requestSub = _requestsRef.child(requestId!).onValue.listen((event) {
      final Object? data = event.snapshot.value;
      if (data is Map<dynamic, dynamic>) {
        final String status = (data['status'] ?? '').toString();
        if (status.isNotEmpty) {
          rideStatus.value = status;
        }
        if (status == 'completed') {
          Get.offNamed(
            '/payment',
            arguments: {'fare': fare, 'pickup': pickup, 'drop': drop},
          );
        }
      }
    });
  }

  void _watchDriverLocation() {
    if (driverId == null) return;
    _driverSub =
        _driversRef.child(driverId!).onValue.listen((DatabaseEvent event) {
      final Object? data = event.snapshot.value;
      if (data is Map<dynamic, dynamic>) {
        final double lat = (data['lat'] ?? 0).toDouble();
        final double lng = (data['lng'] ?? 0).toDouble();
        _driverPosition = LatLng(lat, lng);
        _updateMarkers();
        _buildRoute();
      }
    });
  }

  Future<void> _buildRoute() async {
    final LatLng start = _driverPosition ?? pickupLatLng;
    final List<LatLng> points =
        await _routeService.fetchRoute(start: start, end: dropLatLng);
    routePoints.assignAll(points);
    if (points.isNotEmpty) {
      _fitRouteBounds(points);
    }
  }

  void _fitRouteBounds(List<LatLng> points) {
    final bounds = LatLngBounds.fromPoints(points);
    mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  void _updateMarkers() {
    final List<Marker> next = [
      Marker(
        point: pickupLatLng,
        width: 42,
        height: 42,
        child: const Icon(
          Icons.my_location,
          color: AppColors.success,
          size: 28,
        ),
      ),
      Marker(
        point: dropLatLng,
        width: 42,
        height: 42,
        child: const Icon(
          Icons.location_on,
          color: AppColors.error,
          size: 30,
        ),
      ),
    ];
    if (_driverPosition != null) {
      next.add(
        Marker(
          point: _driverPosition!,
          width: 42,
          height: 42,
          child: const Icon(
            Icons.navigation,
            color: Colors.green,
            size: 28,
          ),
        ),
      );
    }
    markers.assignAll(next);
  }

  void confirmSafety() {
    showGuardianAlert.value = false;
    isSafe.value = true;
    Get.snackbar(
      'Guardian Angel',
      'Glad you are safe! We are continuing to monitor your ride.',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  void onClose() {
    _requestSub?.cancel();
    _driverSub?.cancel();
    super.onClose();
  }

  void callRider() => Get.snackbar(
    'Calling',
    'Connecting to Captain...',
    backgroundColor: AppColors.success,
    colorText: Colors.white,
  );
  void chatWithRider() => Get.to(() => const ChatScreen());

  String getStatusTitle() {
    switch (rideStatus.value) {
      case 'accepted':
        return 'Captain Accepted';
      case 'arriving':
        return 'Captain Arriving';
      case 'ongoing':
        return 'On the way';
      default:
        return 'Completed';
    }
  }
}

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RideDetailsController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Map Background
          Positioned.fill(
            child: Obx(
              () => FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: controller.pickupLatLng,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.rapido.ui',
                  ),
                  if (controller.routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: controller.routePoints,
                          strokeWidth: 5,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  MarkerLayer(markers: controller.markers),
                ],
              ),
            ),
          ),

          // Guardian Angel Overlay
          Obx(
            () => controller.showGuardianAlert.value
                ? Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.8),
                      child: Center(
                        child: ZoomIn(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.security_rounded,
                                    color: AppColors.error,
                                    size: 50,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Guardian Angel Alert',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'We noticed a route deviation. Are you safe?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            controller.confirmSafety(),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          side: const BorderSide(
                                            color: Colors.grey,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'I am Safe',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => Get.snackbar(
                                          'Alerting',
                                          'Emergency contacts notified.',
                                          backgroundColor: AppColors.error,
                                          colorText: Colors.white,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Help Me',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // 2. Top Banner
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: FadeInDown(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: AppColors.primaryBlack,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => Text(
                        controller.getStatusTitle(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Information Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeInUp(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // OTP & Ride Info Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ride Pin: 9821',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'White Honda Activa',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Text(
                                  'KA 01 EK 4567',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/images/rides/bike.png',
                              width: 60,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),

                      // Captain Card
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryYellow,
                            child: const Icon(
                              Icons.person,
                              size: 35,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.rider.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.primaryYellow,
                                      size: 16,
                                    ),
                                    Text(
                                      controller.rider.rating.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '| 1200+ Rides',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildCircleAction(
                            Icons.phone_rounded,
                            AppColors.success,
                            controller.callRider,
                          ),
                          const SizedBox(width: 12),
                          _buildCircleAction(
                            Icons.chat_bubble_rounded,
                            AppColors.info,
                            controller.chatWithRider,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Safety Indicator
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your ride is insured. Travel safely!',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Cancel Button
                      SizedBox(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: const Text(
                            'Cancel Ride',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
