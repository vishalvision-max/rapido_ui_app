import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/colors.dart';

/// Ride selection controller
class RideSelectionController extends GetxController {
  late String pickup;
  late String drop;
  late double pickupLat;
  late double pickupLng;
  late double dropLat;
  late double dropLng;
  final RxString selectedRideType = 'bike'.obs;
  final RxDouble estimatedFare = 45.0.obs;
  final RxDouble bidFare = 45.0.obs;
  final RxBool isBidding = false.obs;
  final RxBool isGroupRide = false.obs;
  final RxInt passengerCount = 1.obs;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments ?? <String, dynamic>{}) as Map<String, dynamic>;
    pickup = (args['pickup'] ?? 'Current Location').toString();
    drop = (args['drop'] ?? '').toString();
    pickupLat = (args['pickupLat'] ?? 0.0).toDouble();
    pickupLng = (args['pickupLng'] ?? 0.0).toDouble();
    dropLat = (args['dropLat'] ?? 0.0).toDouble();
    dropLng = (args['dropLng'] ?? 0.0).toDouble();
    calculateFare();
  }

  void calculateFare() {
    if (selectedRideType.value == 'bike') {
      estimatedFare.value = 45.0;
    } else if (selectedRideType.value == 'auto') {
      estimatedFare.value = 75.0;
    } else {
      estimatedFare.value = 120.0;
    }

    if (isGroupRide.value) {
      estimatedFare.value *= passengerCount.value;
    }

    bidFare.value = estimatedFare.value;
  }

  void toggleGroupRide(bool value) {
    isGroupRide.value = value;
    if (!value) passengerCount.value = 1;
    calculateFare();
  }

  void updatePassengerCount(int count) {
    if (count >= 1 && count <= 5) {
      passengerCount.value = count;
      calculateFare();
    }
  }

  void updateBid(double delta) {
    if (bidFare.value + delta >= (estimatedFare.value * 0.7)) {
      // Limit lower bid
      bidFare.value += delta;
    }
  }

  void openBiddingPanel(BuildContext context) {
    isBidding.value = true;
    // We will call the UI method via a callback or just keep it in logic
  }

  void confirmRide() {
    Get.toNamed(
      '/searching-rider',
      arguments: {
        'pickup': pickup,
        'drop': drop,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'dropLat': dropLat,
        'dropLng': dropLng,
        'rideType': selectedRideType.value,
        'fare': estimatedFare.value,
      },
    );
  }
}

class RideSelectionScreen extends StatelessWidget {
  const RideSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RideSelectionController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Choose a Ride',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Route Summary
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.my_location,
                      color: AppColors.success,
                      size: 20,
                    ),
                    Container(width: 2, height: 20, color: Colors.grey[300]),
                    const Icon(
                      Icons.location_on,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.pickup,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        controller.drop,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: AppColors.primaryYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Ride Options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 10),
                FadeInLeft(
                  child: _buildRideCard(
                    controller,
                    'bike',
                    'Bike',
                    'assets/images/rides/bike.png',
                    45,
                    '2 mins away',
                    'Fastest',
                  ),
                ),
                const SizedBox(height: 12),
                FadeInLeft(
                  delay: const Duration(milliseconds: 100),
                  child: _buildRideCard(
                    controller,
                    'auto',
                    'Auto',
                    'assets/images/rides/auto.png',
                    75,
                    '5 mins away',
                    'Comfortable',
                  ),
                ),
                const SizedBox(height: 12),
                FadeInLeft(
                  delay: const Duration(milliseconds: 200),
                  child: _buildRideCard(
                    controller,
                    'cab',
                    'Cab',
                    'assets/images/rides/cab.png',
                    120,
                    '8 mins away',
                    'AC Comfort',
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Group Ride Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.group_rounded, color: Colors.blue),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Group Ride',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Book for multiple friends',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(
                          () => Switch(
                            value: controller.isGroupRide.value,
                            onChanged: controller.toggleGroupRide,
                            activeColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Obx(
                    () => controller.isGroupRide.value
                        ? FadeIn(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Number of Passengers:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _bidCircleAction(
                                        Icons.remove,
                                        () => controller.updatePassengerCount(
                                          controller.passengerCount.value - 1,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Text(
                                        '${controller.passengerCount.value}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      _bidCircleAction(
                                        Icons.add,
                                        () => controller.updatePassengerCount(
                                          controller.passengerCount.value + 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const Divider(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Personal Account',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Text(
                        'Cash',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showBiddingBottomSheet(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primaryYellow,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Bargain',
                            style: TextStyle(
                              color: AppColors.primaryBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: AppColors.primaryBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          onPressed: () => confirmRideWithFare(
                            controller.estimatedFare.value,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Book ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  controller.selectedRideType.value
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void confirmRideWithFare(double fare) {
    final controller = Get.find<RideSelectionController>();
    Get.toNamed(
      '/searching-rider',
      arguments: {
        'pickup': controller.pickup,
        'drop': controller.drop,
        'pickupLat': controller.pickupLat,
        'pickupLng': controller.pickupLng,
        'dropLat': controller.dropLat,
        'dropLng': controller.dropLng,
        'rideType': controller.selectedRideType.value,
        'fare': fare,
      },
    );
  }

  void _showBiddingBottomSheet(BuildContext context) {
    final controller = Get.find<RideSelectionController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your Offer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Original Fare: ₹${controller.estimatedFare.value.toInt()}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _bidCircleAction(Icons.remove, () => controller.updateBid(-5)),
                const SizedBox(width: 30),
                Obx(
                  () => Text(
                    '₹${controller.bidFare.value.toInt()}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                _bidCircleAction(Icons.add, () => controller.updateBid(5)),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  confirmRideWithFare(controller.bidFare.value);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Send Bid to Captains',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _bidCircleAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(icon, color: AppColors.primaryBlack, size: 28),
      ),
    );
  }

  Widget _buildRideCard(
    RideSelectionController controller,
    String type,
    String title,
    String image,
    double fare,
    String time,
    String tag,
  ) {
    return Obx(() {
      bool isSelected = controller.selectedRideType.value == type;
      return GestureDetector(
        onTap: () {
          controller.selectedRideType.value = type;
          controller.calculateFare();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryYellow : Colors.grey[200]!,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryYellow.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Image.asset(image, width: 80, height: 60, fit: BoxFit.contain),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '₹$fare',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
