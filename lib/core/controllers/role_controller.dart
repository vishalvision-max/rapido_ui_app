import 'package:get/get.dart';
import '../models/user.dart';

class RoleController extends GetxController {
  final Rx<UserRole> currentRole = UserRole.customer.obs;

  void setRole(UserRole role) {
    currentRole.value = role;
    // Update dummy user role as well if needed,
    // but globally currentRole will drive the UI
  }

  bool get isRider => currentRole.value == UserRole.rider;
  bool get isCustomer => currentRole.value == UserRole.customer;
}
