import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EarningsDashboardScreen extends StatelessWidget {
  const EarningsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Earnings Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildQuickStats(),
            _buildEarningsChart(),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.blue[900],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem("Today", "₹450"),
              _statItem("Target", "₹800"),
              _statItem("Incentive", "₹50"),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            minHeight: 8,
          ),
          const SizedBox(height: 10),
          const Text(
            "₹350 more to reach day target",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsChart() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Earnings",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _bar(0.4, "Mon"),
                _bar(0.7, "Tue"),
                _bar(0.5, "Wed"),
                _bar(0.9, "Thu"),
                _bar(0.6, "Fri"),
                _bar(0.8, "Sat"),
                _bar(0.3, "Sun"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double heightPercent, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: 100 * heightPercent,
          decoration: BoxDecoration(
            color: Colors.blue[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daily Activity",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextButton(onPressed: () {}, child: const Text("View All")),
            ],
          ),
          _activityTile("Ride completed (2.5km)", "₹42", "10:30 AM"),
          _activityTile("Ride completed (1.2km)", "₹25", "09:45 AM"),
          _activityTile("Day started", "Online", "08:00 AM"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _activityTile(String title, String value, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
