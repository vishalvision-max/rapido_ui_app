import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'About Rapido',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Rapido_logo.svg/1200px-Rapido_logo.svg.png',
                width: 150,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.directions_bike,
                  size: 100,
                  color: AppColors.primaryYellow,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rapido - Bike Taxi & Auto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Version 5.12.0',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),
            _buildAboutTile('Terms of Service', () {}),
            _buildAboutTile('Privacy Policy', () {}),
            _buildAboutTile('Open Source Licenses', () {}),
            _buildAboutTile('Rate us on Play Store', () {}),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Rapido is India\'s largest bike taxi service, providing a fast and affordable way to commute within the city.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTile(String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      title: Text(title),
      trailing: const Icon(
        Icons.open_in_new,
        size: 18,
        color: AppColors.textSecondary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
