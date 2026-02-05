import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/colors.dart';
import '../../core/models/user.dart';
import '../../core/controllers/role_controller.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roleController = Get.find<RoleController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to Rapido",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please select how you want to use the app",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: _buildRoleCard(
                  title: "Customer",
                  description: "I want to book a ride or send packages",
                  icon: Icons.directions_bike_rounded,
                  color: AppColors.primaryYellow,
                  onTap: () {
                    roleController.setRole(UserRole.customer);
                    Get.offAllNamed('/home');
                  },
                ),
              ),
              const SizedBox(height: 20),
              FadeInRight(
                delay: const Duration(milliseconds: 400),
                child: _buildRoleCard(
                  title: "Captain",
                  description: "I want to earn by giving rides to others",
                  icon: Icons.sports_motorsports_rounded,
                  color: Colors.blue[700]!,
                  onTap: () {
                    roleController.setRole(UserRole.rider);
                    Get.offAllNamed('/rider-home');
                  },
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
