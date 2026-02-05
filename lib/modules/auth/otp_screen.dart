import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/colors.dart';
import '../../core/controllers/role_controller.dart';

class OtpController extends GetxController {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  final RxBool isLoading = false.obs;
  final RxInt resendTimer = 30.obs;
  late String phoneNumber;
  late String verificationId;
  int? resendToken;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments ?? <String, dynamic>{}) as Map<String, dynamic>;
    phoneNumber = (args['phone'] ?? '+91').toString();
    verificationId = (args['verificationId'] ?? '').toString();
    resendToken = args['resendToken'] as int?;
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

  Future<void> verifyOtp() async {
    final String code = otpControllers.map((c) => c.text).join();
    if (code.length != 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the 6-digit code',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    isLoading.value = true;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      await _auth.signInWithCredential(credential);
      final roleController = Get.find<RoleController>();
      await roleController.ensureUserRecord();
      final role = await roleController.fetchRole();
      if (role == null) {
        Get.offAllNamed('/role-selection');
      } else if (roleController.isRider) {
        Get.offAllNamed('/rider-home');
      } else {
        Get.offAllNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Verification Failed',
        e.message ?? 'Invalid OTP',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (resendTimer.value > 0) return;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
      final roleController = Get.find<RoleController>();
      await roleController.ensureUserRecord();
      final role = await roleController.fetchRole();
      if (role == null) {
        Get.offAllNamed('/role-selection');
        } else if (roleController.isRider) {
          Get.offAllNamed('/rider-home');
        } else {
          Get.offAllNamed('/home');
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar(
          'OTP Failed',
          e.message ?? 'Unable to resend OTP',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      },
      codeSent: (String verificationId, int? token) {
        this.verificationId = verificationId;
        resendToken = token;
        startResendTimer();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
      },
    );
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
                            onPressed: controller.resendOtp,
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
