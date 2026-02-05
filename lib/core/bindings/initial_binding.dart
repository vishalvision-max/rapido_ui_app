import 'package:get/get.dart';
import '../../modules/home/home_content.dart';
import '../../modules/ride/ride_history_screen.dart';
import '../../modules/payment/wallet_screen.dart';
import '../../modules/home/home_screen.dart';
import '../controllers/role_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RoleController(), permanent: true);
    Get.lazyPut(() => MainNavigationController());
    Get.lazyPut(() => HomeContentController());
    Get.lazyPut(() => RideHistoryController());
    Get.lazyPut(() => WalletController());
  }
}
