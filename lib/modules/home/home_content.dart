import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:latlong2/latlong.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../models/driver_location_model.dart';
import '../../services/place_search_service.dart';
import '../../services/route_service.dart';

/// Home content controller
class HomeContentController extends GetxController {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropController = TextEditingController();
  final RxString selectedService = 'Bike'.obs;

  final MapController mapController = MapController();
  final Rx<LatLng> currentPosition = const LatLng(12.9716, 77.5946).obs;
  final RxBool isLoadingLocation = false.obs;
  final RxList<Marker> markers = <Marker>[].obs;
  final RxMap<String, DriverLocationModel> _driverLocations =
      <String, DriverLocationModel>{}.obs;
  final DatabaseReference _driversRef = FirebaseDatabase.instance.ref(
    AppConstants.driversPath,
  );
  StreamSubscription<DatabaseEvent>? _driversSubscription;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<User?>? _authSubscription;
  final PlaceSearchService _placeSearchService = PlaceSearchService();
  final RouteService _routeService = RouteService();
  static const double _nearbyRadiusMeters = 3000;
  final RxList<PlaceSearchResult> searchResults = <PlaceSearchResult>[].obs;
  final RxBool searching = false.obs;
  final Rx<ActiveSearchField> activeField = ActiveSearchField.pickup.obs;
  Timer? _searchDebounce;

  LatLng? pickupLatLng;
  LatLng? dropLatLng;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool routeLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentLocation();
    _startLocationStream();
    _bindAuth();
  }

  void _bindAuth() {
    _authSubscription?.cancel();
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _driversSubscription?.cancel();
        _driversSubscription = null;
        _driverLocations.clear();
        _updateMarkers();
      } else {
        _startDriverListener();
      }
    });
    if (FirebaseAuth.instance.currentUser != null) {
      _startDriverListener();
    }
  }

  Future<void> fetchCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      currentPosition.value = LatLng(position.latitude, position.longitude);
      if (pickupController.text.isEmpty) {
        pickupController.text = "Current Location";
        pickupLatLng = currentPosition.value;
      }
      _updateMarkers();
      _updateMapCamera();
    } catch (e) {
      debugPrint('Location Fetch Error: $e');
    } finally {
      isLoadingLocation.value = false;
    }
  }

  void _startLocationStream() {
    _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          currentPosition.value = LatLng(position.latitude, position.longitude);
          if (pickupLatLng == null &&
              pickupController.text == "Current Location") {
            pickupLatLng = currentPosition.value;
          }
          _updateMarkers();
        });
  }

  void setActiveField(ActiveSearchField field) {
    activeField.value = field;
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    if (activeField.value == ActiveSearchField.pickup) {
      pickupLatLng = null;
    } else {
      dropLatLng = null;
    }
    routePoints.clear();
    _updateMarkers();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      final String query = value.trim();
      if (query.isEmpty) {
        searchResults.clear();
        searching.value = false;
        return;
      }
      searching.value = true;
      final List<PlaceSearchResult> results = await _placeSearchService.search(
        query,
        near: currentPosition.value,
        radiusKm: 5,
      );
      searchResults.assignAll(results);
      searching.value = false;
    });
  }

  void selectSearchResult(PlaceSearchResult result) {
    if (activeField.value == ActiveSearchField.pickup) {
      pickupController.text = result.displayName;
      pickupLatLng = result.location;
    } else {
      dropController.text = result.displayName;
      dropLatLng = result.location;
    }

    mapController.move(result.location, 16);
    searchResults.clear();
    _updateMarkers();
    _tryBuildRoute();
  }

  void useCurrentLocationForPickup() {
    pickupController.text = "Current Location";
    pickupLatLng = currentPosition.value;
    mapController.move(currentPosition.value, 16);
    searchResults.clear();
    _updateMarkers();
    _tryBuildRoute();
  }

  Future<void> _tryBuildRoute() async {
    if (pickupLatLng == null || dropLatLng == null) return;
    routeLoading.value = true;
    final List<LatLng> points = await _routeService.fetchRoute(
      start: pickupLatLng!,
      end: dropLatLng!,
    );
    routePoints.assignAll(points);
    routeLoading.value = false;
    if (points.isNotEmpty) {
      _fitRouteBounds(points);
    }
  }

  void _fitRouteBounds(List<LatLng> points) {
    final LatLngBounds bounds = LatLngBounds.fromPoints(points);
    mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  void _startDriverListener() {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    _driversSubscription?.cancel();
    _driversSubscription = _driversRef
        .orderByChild('isOnline')
        .equalTo(true)
        .onValue
        .listen((event) {
          final Object? data = event.snapshot.value;
          if (data is Map<dynamic, dynamic>) {
            final Map<String, DriverLocationModel> parsed = {};
            data.forEach((key, value) {
              if (value is Map<dynamic, dynamic>) {
                parsed[key.toString()] = DriverLocationModel.fromMap(value);
              }
            });
            _driverLocations.assignAll(parsed);
          } else {
            _driverLocations.clear();
          }
          _updateMarkers();
        });
  }

  void _updateMarkers() {
    final List<Marker> nextMarkers = [
      Marker(
        point: currentPosition.value,
        width: 48,
        height: 48,
        child: const Icon(
          Icons.my_location,
          color: AppColors.primaryYellow,
          size: 36,
        ),
      ),
    ];

    if (pickupLatLng != null) {
      nextMarkers.add(
        Marker(
          point: pickupLatLng!,
          width: 44,
          height: 44,
          child: const Icon(
            Icons.my_location,
            color: AppColors.success,
            size: 30,
          ),
        ),
      );
    }

    if (dropLatLng != null) {
      nextMarkers.add(
        Marker(
          point: dropLatLng!,
          width: 44,
          height: 44,
          child: const Icon(
            Icons.location_on,
            color: AppColors.error,
            size: 32,
          ),
        ),
      );
    }

    final LatLng center = currentPosition.value;
    _driverLocations.forEach((driverId, driver) {
      if (!driver.isOnline) return;
      final double distance = Geolocator.distanceBetween(
        center.latitude,
        center.longitude,
        driver.lat,
        driver.lng,
      );
      if (distance <= _nearbyRadiusMeters) {
        nextMarkers.add(
          Marker(
            point: LatLng(driver.lat, driver.lng),
            width: 40,
            height: 40,
            child: const Icon(Icons.navigation, color: Colors.green, size: 28),
          ),
        );
      }
    });

    markers.assignAll(nextMarkers);
  }

  void _updateMapCamera() {
    mapController.move(currentPosition.value, 16);
  }

  @override
  void onClose() {
    _driversSubscription?.cancel();
    _positionSubscription?.cancel();
    _authSubscription?.cancel();
    _searchDebounce?.cancel();
    pickupController.dispose();
    dropController.dispose();
    super.onClose();
  }

  void bookRide() {
    if (pickupLatLng == null || dropLatLng == null) {
      Get.snackbar(
        'Missing location',
        'Please choose pickup and drop locations',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    if (routePoints.isEmpty) {
      Get.snackbar(
        'Route not ready',
        'Please wait for the route to load',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    if (dropController.text.isEmpty) {
      Get.snackbar(
        'Where to?',
        'Please enter a destination',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    Get.toNamed(
      '/ride-selection',
      arguments: {
        'pickup': pickupController.text.isEmpty
            ? "Current Location"
            : pickupController.text,
        'drop': dropController.text,
        'pickupLat': pickupLatLng!.latitude,
        'pickupLng': pickupLatLng!.longitude,
        'dropLat': dropLatLng!.latitude,
        'dropLng': dropLatLng!.longitude,
      },
    );
  }
}

enum ActiveSearchField { pickup, drop }

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeContentController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // 1. Full Screen Map
          Obx(
            () => FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.currentPosition.value,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.rapido.ui',
                ),
                if (controller.routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: controller.routePoints,
                        strokeWidth: 5,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                MarkerLayer(markers: controller.markers),
              ],
            ),
          ),

          // 2. Custom App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showSafetyMenu(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Get.to(() => const NotificationsScreen()),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Get.to(() => const RapidoCoinsScreen()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: AppColors.primaryYellow,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '45 Coins',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Sheet UI (Expandable & Draggable)
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.12,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Promo Banner
                    Container(
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildPromoCard(
                            'assets/images/promo1.png',
                            '50% OFF on your first Auto ride',
                            AppColors.primaryYellow,
                          ),
                          _buildPromoCard(
                            'assets/images/promo2.png',
                            'Refer & Earn ₹50 per friend',
                            Colors.blue[100]!,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Search / Booking Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showSearchDialog(context, controller),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  color: AppColors.primaryYellow,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Where are you going?',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 30),
                          Obx(
                            () => Row(
                              children: [
                                _buildServiceItem(
                                  context,
                                  'Bike',
                                  'assets/images/rides/bike.png',
                                  controller.selectedService.value == 'Bike',
                                  () =>
                                      controller.selectedService.value = 'Bike',
                                ),
                                _buildServiceItem(
                                  context,
                                  'Auto',
                                  'assets/images/rides/auto.png',
                                  controller.selectedService.value == 'Auto',
                                  () =>
                                      controller.selectedService.value = 'Auto',
                                ),
                                _buildServiceItem(
                                  context,
                                  'Cab',
                                  'assets/images/rides/cab.png',
                                  controller.selectedService.value == 'Cab',
                                  () =>
                                      controller.selectedService.value = 'Cab',
                                ),
                                _buildServiceItem(
                                  context,
                                  'Box',
                                  'assets/images/rides/box.png',
                                  controller.selectedService.value == 'Box',
                                  () =>
                                      controller.selectedService.value = 'Box',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Saved Places / Recommendations
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saved & Recent Places',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSavedPlaceItem(
                            Icons.home_rounded,
                            'Home',
                            '123, Maple Street, Apartment 4B',
                            '2.5 km',
                          ),
                          _buildSavedPlaceItem(
                            Icons.work_rounded,
                            'Work',
                            'Tech Park, Building C, 5th Floor',
                            '8.2 km',
                          ),
                          _buildSavedPlaceItem(
                            Icons.history_rounded,
                            'Recent: MG Road',
                            'The Central Mall, Entrance 2',
                            '4.1 km',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlaceItem(
    IconData icon,
    String title,
    String address,
    String distance,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlack, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  address,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            distance,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(String? image, String text, Color bgColor) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ],
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    String title,
    String imagePath,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 60,
              width: 80,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryYellow.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryYellow
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(
    BuildContext context,
    HomeContentController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Plan Your Ride',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller.pickupController,
              onTap: () => controller.setActiveField(ActiveSearchField.pickup),
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.my_location,
                  color: AppColors.success,
                ),
                hintText: 'From',
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.dropController,
              onTap: () => controller.setActiveField(ActiveSearchField.drop),
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.location_on,
                  color: AppColors.error,
                ),
                hintText: 'To',
                fillColor: Colors.grey[100],
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Obx(() {
              final bool showCurrentLocationOption =
                  controller.activeField.value == ActiveSearchField.pickup &&
                  controller.pickupController.text.isEmpty;
              final bool showList = controller.searchResults.isNotEmpty;
              if (!showCurrentLocationOption && !showList) {
                return const SizedBox.shrink();
              }
              return Container(
                constraints: const BoxConstraints(maxHeight: 260),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (showCurrentLocationOption)
                      ListTile(
                        leading: const Icon(
                          Icons.my_location,
                          color: AppColors.success,
                        ),
                        title: const Text('Use current location'),
                        onTap: controller.useCurrentLocationForPickup,
                      ),
                    if (controller.searching.value)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    if (!controller.searching.value)
                      ...controller.searchResults.map(
                        (result) => ListTile(
                          leading: const Icon(Icons.place_rounded),
                          title: Text(
                            result.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => controller.selectSearchResult(result),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.routeLoading.value
                      ? null
                      : () {
                          Get.back();
                          controller.bookRide();
                        },
                  child: controller.routeLoading.value
                      ? const Text('Loading route...')
                      : const Text('OK'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSafetyMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Safety Tools',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'We are here to help you stay safe.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildSafetyItem(
              Icons.share_location_rounded,
              'Share My Ride',
              'Let your friends and family track your live location.',
            ),
            _buildSafetyItem(
              Icons.local_police_rounded,
              'Call Police',
              'Quickly call 100 in case of an emergency.',
              color: AppColors.error,
            ),
            _buildSafetyItem(
              Icons.info_outline_rounded,
              'Safety Hotline',
              'Call Rapido safety team for any ride concerns.',
            ),
            const SizedBox(height: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyItem(
    IconData icon,
    String title,
    String subtitle, {
    Color? color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primaryBlack).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? AppColors.primaryBlack),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: () {},
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationItem(
            '50% OFF!',
            'Get 50% off on your next 3 rides. Use code: RIDE50',
            '2 hours ago',
            true,
          ),
          _buildNotificationItem(
            'Wallet Updated',
            'Your wallet balance has been topped up with ₹500.',
            'Yesterday',
            false,
          ),
          _buildNotificationItem(
            'New Service: Box',
            'Now deliver packages across the city with Rapido Box.',
            '2 days ago',
            true,
          ),
          _buildNotificationItem(
            'Safety Update',
            'We have introduced 24/7 Safety Hotline for your security.',
            '3 days ago',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String body,
    String time,
    bool isPromo,
  ) {
    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPromo
                        ? AppColors.secondaryYellow
                        : AppColors.primaryBlack,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class RapidoCoinsScreen extends StatelessWidget {
  const RapidoCoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Rapido Coins',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: const BoxDecoration(
                  gradient: AppColors.yellowGradient,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      size: 80,
                      color: AppColors.primaryBlack,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '45 Coins',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    Text(
                      '₹45.00 Value',
                      style: TextStyle(
                        color: AppColors.primaryBlack.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildCoinTask(
              'Complete 5 rides this week',
              'Earn 50 coins',
              'InProgress',
            ),
            _buildCoinTask('Refer a friend', 'Earn 100 coins', 'Pending'),
            _buildCoinTask('Profile Completion', 'Earn 25 coins', 'Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinTask(String title, String reward, String status) {
    return ListTile(
      leading: const Icon(
        Icons.task_alt_rounded,
        color: AppColors.primaryYellow,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(reward),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: status == 'Completed' ? Colors.green[50] : Colors.orange[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: status == 'Completed' ? Colors.green : Colors.orange,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              FadeInDown(
                child: const Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryYellow,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'How was your ride?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rate your Captain Rajesh Kumar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star_outline_rounded,
                    size: 45,
                    color: AppColors.primaryYellow,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ratingTag('Safe Driving'),
                  _ratingTag('Punctual'),
                  _ratingTag('Polite'),
                  _ratingTag('Clean Bike'),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.primaryBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Submit Rating',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ratingTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
