import 'package:get/get.dart';

class RiderHomeController extends GetxController {
  final RxBool isOnline = false.obs;
  final RxDouble todayEarnings = 0.0.obs;
  final RxInt completedRides = 0.obs;
  final RxDouble rating = 4.8.obs;

  void toggleDuty() {
    isOnline.value = !isOnline.value;
    if (isOnline.value) {
      Get.snackbar(
        'Online',
        'You are now visible to customers',
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Offline',
        'You are no longer accepting rides',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
