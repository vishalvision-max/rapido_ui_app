import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/colors.dart';

class OtpController extends GetxController {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  final RxBool isLoading = false.obs;
  final RxInt resendTimer = 30.obs;
  late String phoneNumber;

  @override
  void onInit() {
    super.onInit();
    phoneNumber = Get.arguments ?? '+91 9876543210';
    startResendTimer();
  }

  void startResendTimer() {
    resendTimer.value = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendTimer.value > 0) {
        resendTimer.value--;
        return true;
      }
      return false;
    });
  }

  void verifyOtp() {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.offAllNamed('/role-selection');
    });
  }
}

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtpController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              FadeInDown(
                child: const Text(
                  'Verify Account',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Enter the 6-digit code sent to\n${controller.phoneNumber}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),

              // OTP Boxes
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => _otpBox(context, index, controller),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Timer
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Center(
                  child: Obx(
                    () => controller.resendTimer.value > 0
                        ? Text(
                            'Resend code in ${controller.resendTimer.value}s',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : TextButton(
                            onPressed: controller.startResendTimer,
                            child: const Text(
                              'Resend Code',
                              style: TextStyle(
                                color: AppColors.primaryYellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const Spacer(),

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
                          : controller.verifyOtp,
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(
                              color: AppColors.primaryBlack,
                            )
                          : const Text(
                              'Verify & Proceed',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(BuildContext context, int index, OtpController controller) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller.otpControllers[index],
        focusNode: controller.focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        maxLength: 1,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.primaryBlack,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            controller.focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            controller.focusNodes[index - 1].requestFocus();
          }
          if (index == 5 && value.isNotEmpty) {
            controller.verifyOtp();
          }
        },
      ),
    );
  }
}
