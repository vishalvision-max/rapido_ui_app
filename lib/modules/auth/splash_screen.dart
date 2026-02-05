import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/colors.dart';
import '../../core/controllers/role_controller.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(seconds: 2));
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.offNamed('/login');
      return;
    }

    final roleController = Get.find<RoleController>();
    final role = await roleController.fetchRole();
    if (role == null) {
      Get.offNamed('/role-selection');
      return;
    }
    if (roleController.isRider) {
      Get.offNamed('/rider-home');
    } else {
      Get.offNamed('/home');
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.yellowGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ZoomIn(
                duration: const Duration(seconds: 1),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.two_wheeler_rounded,
                          size: 70,
                          color: AppColors.primaryYellow,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'RAPIDO',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryYellow,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeIn(
                delay: const Duration(seconds: 1),
                child: const Text(
                  'India\'s Largest Bike Taxi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeIn(
                delay: const Duration(seconds: 1),
                child: SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlack.withValues(alpha: 0.5),
                    ),
                    minHeight: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
