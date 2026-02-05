import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/colors.dart';
import '../../core/models/ride.dart';

class RideHistoryController extends GetxController {
  final RxList<Ride> rideHistory = <Ride>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRideHistory();
  }

  void loadRideHistory() {
    rideHistory.value = Ride.getDummyRideHistory();
  }
}

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RideHistoryController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Rides',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(
        () => controller.rideHistory.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: controller.rideHistory.length,
                itemBuilder: (context, index) {
                  final ride = controller.rideHistory[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 100),
                    child: _buildRideCard(context, ride),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No rides found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your journey logs will appear here.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, Ride ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getRideIcon(ride.rideType),
                    color: AppColors.primaryYellow,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ride.rideType.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Text(
                ride.bookingTime != null
                    ? DateFormat('dd MMM, hh:mm a').format(ride.bookingTime!)
                    : '',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 10, color: AppColors.success),
                  Container(width: 2, height: 25, color: Colors.grey[200]),
                  const Icon(Icons.circle, size: 10, color: AppColors.error),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.pickupLocation,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      ride.dropLocation,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${ride.fare.toInt()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${ride.distance.toStringAsFixed(1)} km',
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getRideIcon(String type) {
    if (type.contains('auto')) return Icons.airport_shuttle;
    if (type.contains('cab')) return Icons.local_taxi;
    return Icons.two_wheeler;
  }
}
