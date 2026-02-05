import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/colors.dart';
import '../../core/models/ride.dart';
import 'chat_screen.dart';

class RideDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late String pickup;
  late String drop;
  late String rideType;
  late double fare;
  late Rider rider;
  final RxString rideStatus = 'accepted'.obs;

  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxBool showGuardianAlert = false.obs;
  final RxBool isSafe = true.obs;

  late AnimationController moveController;
  late Animation<LatLng> markerPositionAnimation;

  final LatLng startPos = const LatLng(12.9716, 77.5946);
  final LatLng endPos = const LatLng(12.9616, 77.5846);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    pickup = args['pickup'] ?? 'Current Location';
    drop = args['drop'] ?? '';
    rideType = args['rideType'] ?? 'bike';
    fare = args['fare'] ?? 0.0;
    rider = Rider.getDummyRider();

    moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    markerPositionAnimation = Tween<LatLng>(
      begin: startPos,
      end: endPos,
    ).animate(moveController);

    moveController.addListener(() {
      _updateMarkerPosition(markerPositionAnimation.value);
    });

    _drawRoute();
    _simulateRideProgress();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    moveController.forward();
  }

  void _drawRoute() {
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [startPos, endPos],
        color: AppColors.primaryYellow,
        width: 5,
        jointType: JointType.round,
        patterns: [PatternItem.dot, PatternItem.gap(10)],
      ),
    );

    _updateMarkerPosition(startPos);
  }

  void _updateMarkerPosition(LatLng pos) {
    markers.assignAll({
      Marker(
        markerId: const MarkerId('rider'),
        position: pos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(title: 'Your Captain'),
        rotation: 45, // Simulating a heading
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: endPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    });
  }

  void _simulateRideProgress() {
    Future.delayed(
      const Duration(seconds: 5),
      () => rideStatus.value = 'ongoing',
    );
    Future.delayed(const Duration(seconds: 15), () {
      if (isSafe.value) {
        // Only finish if user says they are safe
        rideStatus.value = 'completed';
        Get.offNamed(
          '/payment',
          arguments: {'fare': fare, 'pickup': pickup, 'drop': drop},
        );
      }
    });

    // Simulate Route Deviation for Guardian Angel after 7 seconds
    Future.delayed(const Duration(seconds: 7), () {
      if (rideStatus.value == 'ongoing') {
        showGuardianAlert.value = true;
        // Shift marker away from route to simulate deviation
        _updateMarkerPosition(const LatLng(12.9650, 77.6000));
      }
    });
  }

  void confirmSafety() {
    showGuardianAlert.value = false;
    isSafe.value = true;
    _updateMarkerPosition(
      markerPositionAnimation.value,
    ); // Snap back to route for simulation
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
    moveController.dispose();
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
              () => GoogleMap(
                onMapCreated: controller.onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(12.9716, 77.5946),
                  zoom: 15,
                ),
                myLocationEnabled: true,
                markers: controller.markers.toSet(),
                polylines: controller.polylines.toSet(),
                zoomControlsEnabled: false,
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
