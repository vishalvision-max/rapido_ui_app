import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/colors.dart';
import '../ride/ride_history_screen.dart';
import '../payment/wallet_screen.dart';
import '../profile/profile_screen.dart';
import 'home_content.dart';
import 'rapido_pass_screen.dart';
import 'offers_screen.dart';
import 'refer_earn_screen.dart';
import 'support_screen.dart';
import 'about_screen.dart';
import '../payment/payment_methods_screen.dart';
import '../../core/controllers/role_controller.dart';

/// Main navigation controller
class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  final List<Widget> screens = [
    const HomeContent(),
    const RideHistoryScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}

/// Main home screen with bottom navigation
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainNavigationController(), permanent: true);
    Get.put(RideHistoryController(), permanent: true);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      drawer: _buildDrawer(context),
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: controller.screens,
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.cardBackground,
              selectedItemColor: AppColors.primaryYellow,
              unselectedItemColor: AppColors.textSecondary.withValues(
                alpha: 0.5,
              ),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_rounded),
                  activeIcon: Icon(Icons.history_rounded),
                  label: 'Rides',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet_rounded),
                  label: 'Wallet',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundColor,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryYellow),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColors.primaryBlack,
              child: Icon(
                Icons.person,
                color: AppColors.primaryYellow,
                size: 40,
              ),
            ),
            accountName: const Text(
              'User Name',
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: const Text(
              '+91 9876543210',
              style: TextStyle(color: AppColors.primaryBlack),
            ),
          ),
          _buildDrawerItem(
            Icons.payment,
            'Payment Methods',
            () => Get.to(() => const PaymentMethodsScreen()),
          ),
          _buildDrawerItem(
            Icons.verified_user_rounded,
            'Rapido Pass',
            () => Get.to(() => const RapidoPassScreen()),
            color: Colors.blue[700],
          ),
          _buildDrawerItem(
            Icons.card_giftcard,
            'Offers',
            () => Get.to(() => const OffersScreen()),
          ),
          _buildDrawerItem(
            Icons.share,
            'Refer & Earn',
            () => Get.to(() => const ReferEarnScreen()),
          ),
          _buildDrawerItem(
            Icons.help_outline,
            'Support',
            () => Get.to(() => const SupportScreen()),
          ),
          _buildDrawerItem(
            Icons.info_outline,
            'About Rapido',
            () => Get.to(() => const AboutScreen()),
          ),
          const Spacer(),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', () async {
            final GoogleSignIn _googleSignIn = GoogleSignIn();

            final roleController = Get.find<RoleController>();
            await roleController.signOut();
            _googleSignIn.signOut();
            Get.offAllNamed('/login');
          }, color: AppColors.error),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primaryBlack),
      title: Text(
        title,
        style: TextStyle(color: color ?? AppColors.textPrimary),
      ),
      onTap: onTap,
    );
  }
}
