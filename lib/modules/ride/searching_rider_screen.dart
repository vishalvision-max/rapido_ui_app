import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/colors.dart';

class SearchingRiderController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late String pickup;
  late String drop;
  late String rideType;
  late double fare;

  late AnimationController pulseController;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    pickup = args['pickup'] ?? 'Current Location';
    drop = args['drop'] ?? '';
    rideType = args['rideType'] ?? 'bike';
    fare = args['fare'] ?? 0.0;

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    pulseController.repeat();

    _searchForRider();
  }

  void _searchForRider() {
    Future.delayed(const Duration(seconds: 5), () {
      Get.offNamed(
        '/ride-details',
        arguments: {
          'pickup': pickup,
          'drop': drop,
          'rideType': rideType,
          'fare': fare,
        },
      );
    });
  }

  @override
  void onClose() {
    pulseController.dispose();
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
                      onPressed: () => Get.back(),
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
