import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/colors.dart';
import '../../core/controllers/role_controller.dart';

class LoginController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final RxBool isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final Rx<CountryCode> selectedCountry = CountryCode(
    name: 'India',
    dialCode: '+91',
    flag: '🇮🇳',
  ).obs;

  final List<CountryCode> countries = const [
    CountryCode(name: 'India', dialCode: '+91', flag: '🇮🇳'),
    CountryCode(name: 'United States', dialCode: '+1', flag: '🇺🇸'),
    CountryCode(name: 'United Kingdom', dialCode: '+44', flag: '🇬🇧'),
    CountryCode(name: 'UAE', dialCode: '+971', flag: '🇦🇪'),
    CountryCode(name: 'Canada', dialCode: '+1', flag: '🇨🇦'),
    CountryCode(name: 'Singapore', dialCode: '+65', flag: '🇸🇬'),
  ];

  Future<void> sendOtp() async {
    final String raw = phoneController.text.trim();
    if (raw.length < 7) {
      Get.snackbar(
        'Invalid Phone',
        'Please enter a valid phone number',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final String number = raw.replaceAll(RegExp(r'\\s+'), '');
    final String fullPhone = '${selectedCountry.value.dialCode}$number';

    isLoading.value = true;
    await _auth.verifyPhoneNumber(
      phoneNumber: fullPhone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        isLoading.value = false;
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
        isLoading.value = false;
        Get.snackbar(
          'Verification Failed',
          e.message ?? 'Unable to send OTP',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        isLoading.value = false;
        Get.toNamed(
          '/otp',
          arguments: {
            'phone': fullPhone,
            'verificationId': verificationId,
            'resendToken': resendToken,
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      debugPrint('Google Sign-In1: start');
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      debugPrint('Google Sign-In2: account=${googleUser?.email}');

      if (googleUser == null) {
        debugPrint('Google Sign-In3: user cancelled');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint(
        'Google Sign-In4: idToken=${googleAuth.idToken != null}, accessToken=${googleAuth.accessToken != null}',
      );

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      debugPrint('Google Sign-In5: firebase auth success');

      final roleController = Get.find<RoleController>();

      debugPrint('Google Sign-In6: ensureUserRecord');
      await roleController.ensureUserRecord();

      debugPrint('Google Sign-In7: fetchRole');
      final role = await roleController.fetchRole();

      debugPrint('Google Sign-In8: role=$role');

      if (role == null) {
        Get.offAllNamed('/role-selection');
      } else if (roleController.isRider) {
        Get.offAllNamed('/rider-home');
      } else {
        Get.offAllNamed('/home');
      }
    } catch (e, st) {
      debugPrint('Google Sign-In9 ERROR: $e');
      debugPrint('STACKTRACE: $st');
    } finally {
      isLoading.value = false;
    }
  }
}

class CountryCode {
  final String name;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.dialCode,
    required this.flag,
  });
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
                      Obx(
                        () => GestureDetector(
                          onTap: () => _showCountryPicker(context, controller),
                          child: Row(
                            children: [
                              Text(
                                '${controller.selectedCountry.value.flag} ${controller.selectedCountry.value.dialCode}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
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
                    GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : controller.signInWithGoogle,
                      child: _socialIcon(Icons.g_mobiledata, Colors.red),
                    ),
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

  void _showCountryPicker(BuildContext context, LoginController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView.separated(
        itemCount: controller.countries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = controller.countries[index];
          return ListTile(
            title: Text('${item.flag} ${item.name}'),
            trailing: Text(item.dialCode),
            onTap: () {
              controller.selectedCountry.value = item;
              Get.back();
            },
          );
        },
      ),
    );
  }
}
