import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/colors.dart';

class LoginController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final RxBool isLoading = false.obs;

  void sendOtp() {
    if (phoneController.text.length < 10) {
      Get.snackbar(
        'Invalid Phone',
        'Please enter a 10-digit phone number',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.toNamed('/otp', arguments: phoneController.text);
    });
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              FadeInDown(
                child: const Icon(
                  Icons.two_wheeler_rounded,
                  size: 60,
                  color: AppColors.primaryYellow,
                ),
              ),
              const SizedBox(height: 20),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Moving billions\nof dreams.',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBlack,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Login to Rapido to start your journey.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
              const SizedBox(height: 50),

              // Phone Input
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '🇮🇳 +91',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Phone Number',
                            border: InputBorder.none,
                            counterText: "",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Button
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.primaryBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.sendOtp,
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(
                              color: AppColors.primaryBlack,
                            )
                          : const Text(
                              'Send OTP',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Social Login Placeholder
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              FadeInUp(
                delay: const Duration(milliseconds: 1200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialIcon(Icons.g_mobiledata, Colors.red),
                    const SizedBox(width: 20),
                    _socialIcon(Icons.facebook, Colors.blue[800]!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FadeInUp(
        delay: const Duration(milliseconds: 1400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'By continuing, you agree to our Terms of Service & Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(icon, size: 30, color: color),
    );
  }
}
