import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/colors.dart';
import '../../core/models/user.dart';
import 'edit_profile_screen.dart';
import '../payment/payment_methods_screen.dart';

/// Profile controller
class ProfileController extends GetxController {
  late User user;

  @override
  void onInit() {
    super.onInit();
    user = User.getDummyUser();
  }

  void editProfile() {
    Get.to(() => const EditProfileScreen());
  }

  void logout() {
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: AppColors.textWhite,
      buttonColor: AppColors.error,
      cancelTextColor: AppColors.textPrimary,
      onConfirm: () {
        Get.back();
        _googleSignIn.signOut();
        Get.offAllNamed('/login');
        Get.snackbar(
          'Success',
          'Logged out successfully',
          backgroundColor: AppColors.success,
          colorText: AppColors.textWhite,
        );
      },
    );
  }
}

/// Profile screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryYellow,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: controller.editProfile,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlack,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.cardBackground,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: AppColors.primaryYellow,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.user.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.user.phone,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (controller.user.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      controller.user.email!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Settings sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildSettingsSection(
                    context: context,
                    title: 'Account',
                    items: [
                      _buildSettingsItem(
                        context: context,
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        onTap: controller.editProfile,
                      ),
                      _buildSettingsItem(
                        context: context,
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        context: context,
                        icon: Icons.payment_outlined,
                        title: 'Payment Methods',
                        onTap: () => Get.to(() => const PaymentMethodsScreen()),
                      ),
                      _buildSettingsItem(
                        context: context,
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSettingsSection(
                    context: context,
                    title: 'Support',
                    items: [
                      _buildSettingsItem(
                        context: context,
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        context: context,
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        context: context,
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSettingsSection(
                    context: context,
                    title: 'More',
                    items: [
                      _buildSettingsItem(
                        context: context,
                        icon: Icons.share_outlined,
                        title: 'Share App',
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        context: context,
                        icon: Icons.star_outline,
                        title: 'Rate Us',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: controller.logout,
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Version
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
