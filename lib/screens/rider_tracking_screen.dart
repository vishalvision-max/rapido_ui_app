import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';
import '../models/driver_location_model.dart';
import '../services/firebase_location_service.dart';
import '../services/place_search_service.dart';
import '../widgets/driver_marker.dart';

class RiderTrackingScreen extends StatefulWidget {
  final String? initialDriverId;

  const RiderTrackingScreen({super.key, this.initialDriverId});

  @override
  State<RiderTrackingScreen> createState() => _RiderTrackingScreenState();
}

class _RiderTrackingScreenState extends State<RiderTrackingScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final FirebaseLocationService _firebaseService = FirebaseLocationService();
  final TextEditingController _driverIdController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final PlaceSearchService _searchService = PlaceSearchService();

  StreamSubscription<DriverLocationModel?>? _driverSubscription;
  DriverLocationModel? _latestLocation;
  LatLng? _animatedPosition;
  DateTime? _lastUpdatedAt;
  List<PlaceSearchResult> _searchResults = [];
  bool _searchLoading = false;

  late final AnimationController _markerController;
  Animation<LatLng>? _markerAnimation;

  @override
  void initState() {
    super.initState();
    _driverIdController.text = widget.initialDriverId ?? '';
    _markerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _markerController.addListener(() {
      if (!mounted) return;
      if (_markerAnimation != null) {
        setState(() {
          _animatedPosition = _markerAnimation!.value;
        });
      }
    });

    if (_driverIdController.text.isNotEmpty) {
      _startListening(_driverIdController.text);
    }
  }

  Future<void> _performSearch() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _searchLoading = true;
    });

    final List<PlaceSearchResult> results =
        await _searchService.search(query);

    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _searchLoading = false;
    });
  }

  void _selectSearchResult(PlaceSearchResult result) {
    _mapController.move(result.location, 16);
    setState(() {
      _searchResults = [];
    });
  }

  void _startListening(String driverId) {
    _driverSubscription?.cancel();

    _driverSubscription =
        _firebaseService.watchDriverLocation(driverId).listen((data) {
      if (data == null) return;
      if (data.updatedAt == null && data.lat == 0 && data.lng == 0) {
        return;
      }

      final LatLng nextPosition = LatLng(data.lat, data.lng);
      final LatLng? prevPosition = _animatedPosition;

      setState(() {
        _latestLocation = data;
        _lastUpdatedAt = data.updatedAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(data.updatedAt!);
      });

      if (prevPosition == null) {
        setState(() {
          _animatedPosition = nextPosition;
        });
        _mapController.move(nextPosition, _mapController.camera.zoom);
        return;
      }

      _markerAnimation = LatLngTween(begin: prevPosition, end: nextPosition)
          .animate(CurvedAnimation(
        parent: _markerController,
        curve: Curves.easeInOut,
      ));
      _markerController.forward(from: 0);
      _mapController.move(nextPosition, _mapController.camera.zoom);
    });
  }

  @override
  void dispose() {
    _driverSubscription?.cancel();
    _markerController.dispose();
    _driverIdController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng mapCenter = _animatedPosition ?? AppConstants.defaultMapCenter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Tracking'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Search location',
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _performSearch,
                          ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                if (_searchResults.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final PlaceSearchResult result = _searchResults[index];
                        return ListTile(
                          title: Text(
                            result.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _driverIdController,
                    decoration: const InputDecoration(
                      labelText: 'Driver ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final String id = _driverIdController.text.trim();
                    if (id.isNotEmpty) {
                      _startListening(id);
                    }
                  },
                  child: const Text('Track'),
                ),
              ],
            ),
          ),
          if (_lastUpdatedAt != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 6),
                  Text('Last update: ${_lastUpdatedAt!.toLocal()}'),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: AppConstants.defaultZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.rapido.ui',
                ),
                if (_animatedPosition != null && _latestLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _animatedPosition!,
                        width: 48,
                        height: 48,
                        child: DriverMarker(
                          position: _animatedPosition!,
                          heading: _latestLocation!.heading,
                          isOnline: _latestLocation!.isOnline,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({super.begin, super.end});

  @override
  LatLng lerp(double t) {
    final double lat = (begin!.latitude + (end!.latitude - begin!.latitude) * t);
    final double lng = (begin!.longitude + (end!.longitude - begin!.longitude) * t);
    return LatLng(lat, lng);
  }
}
