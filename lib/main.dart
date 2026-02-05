import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'core/theme/app_theme.dart';
import 'modules/auth/splash_screen.dart';
import 'modules/auth/login_screen.dart';
import 'modules/auth/otp_screen.dart';
import 'modules/home/home_screen.dart';
import 'modules/ride/ride_selection_screen.dart';
import 'modules/ride/searching_rider_screen.dart';
import 'modules/ride/ride_details_screen.dart';
import 'modules/payment/payment_screen.dart';
import 'modules/auth/role_selection_screen.dart';
import 'modules/rider/rider_home_screen.dart';
import 'modules/rider/earnings_dashboard_screen.dart';
import 'modules/rider/rider_ride_history_screen.dart';
import 'modules/rider/redeem_earnings_screen.dart';
import 'modules/rider/captain_documents_screen.dart';
import 'core/bindings/initial_binding.dart';
import 'core/firebase_config.dart';
import 'screens/driver_map_screen.dart';
import 'screens/rider_tracking_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.init();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  runApp(const RapidoApp());
}

/// Main application widget
class RapidoApp extends StatelessWidget {
  const RapidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rapido UI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),

      // Initial route
      initialRoute: '/',

      // Route definitions
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/otp',
          page: () => const OtpScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/ride-selection',
          page: () => const RideSelectionScreen(),
          transition: Transition.upToDown,
        ),
        GetPage(
          name: '/searching-rider',
          page: () => const SearchingRiderScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/ride-details',
          page: () => const RideDetailsScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/payment',
          page: () => const PaymentScreen(),
          transition: Transition.upToDown,
        ),
        GetPage(
          name: '/role-selection',
          page: () => const RoleSelectionScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/rider-home',
          page: () => const RiderHomeScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/rider-earnings',
          page: () => const EarningsDashboardScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/rider-history',
          page: () => const RiderRideHistoryScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/rider-redeem',
          page: () => const RedeemEarningsScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/rider-docs',
          page: () => const CaptainDocumentsScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/driver-map',
          page: () => const DriverMapScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/rider-tracking',
          page: () => const RiderTrackingScreen(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
