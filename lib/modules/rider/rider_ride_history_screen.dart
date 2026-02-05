import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RiderRideHistoryScreen extends StatelessWidget {
  const RiderRideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Ride History",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildHistoryCard(index);
        },
      ),
    );
  }

  Widget _buildHistoryCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ID: RAP${1000 + index}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Completed",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 12, color: Colors.blue),
                  Container(width: 2, height: 20, color: Colors.grey[300]),
                  const Icon(Icons.location_on, size: 12, color: Colors.red),
                ],
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Indiranagar Stage 2",
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "HSR Layout Sector 4",
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "₹85.00",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "3.5 km",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              const Text(
                "Today, 10:25 AM",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Spacer(),
              _ratingStars(4.5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingStars(double rating) {
    return Row(
      children: [
        const Icon(Icons.star, size: 14, color: Colors.orange),
        const SizedBox(width: 4),
        Text(
          rating.toString(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
