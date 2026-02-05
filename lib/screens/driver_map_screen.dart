import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';
import '../services/firebase_location_service.dart';
import '../services/location_service.dart';
import '../services/ride_request_service.dart';
import '../widgets/driver_marker.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final FirebaseLocationService _firebaseService = FirebaseLocationService();
  final RideRequestService _rideRequestService = RideRequestService();
  final DatabaseReference _rideRequestsRef = FirebaseDatabase.instance.ref(
    'rideRequests',
  );

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<DatabaseEvent>? _requestsSubscription;
  StreamSubscription<User?>? _authSubscription;
  LatLng? _currentPosition;
  double _currentHeading = 0;
  bool _isOnline = false;
  bool _permissionOk = false;
  bool _loading = true;
  String? _driverId;
  List<_RideRequest> _allRequests = [];
  List<_RideRequest> _nearbyRequests = [];
  _RideRequest? _activeRequest;
  String _activeStatus = 'accepted';
  static const double _nearbyRadiusMeters = 3000;

  @override
  void initState() {
    super.initState();
    _init();
    _bindAuth();
  }

  Future<void> _init() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _driverId = null;
        _loading = false;
      });
      return;
    }

    _driverId = user.uid;

    final bool permissionOk = await _locationService.ensurePermission();
    final Position? current = await _locationService.getCurrentPosition();

    setState(() {
      _permissionOk = permissionOk;
      _currentPosition = current == null
          ? null
          : LatLng(current.latitude, current.longitude);
      _loading = false;
    });
  }

  void _bindAuth() {
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _requestsSubscription?.cancel();
        _requestsSubscription = null;
        if (mounted) {
          setState(() {
            _nearbyRequests = [];
            _allRequests = [];
          });
        }
      } else if (_isOnline) {
        _startRequestListener();
      }
    });
  }

  Future<void> _goOnline() async {
    if (_driverId == null) return;
    final bool permissionOk = await _locationService.ensurePermission();
    if (!permissionOk) {
      setState(() {
        _permissionOk = false;
      });
      return;
    }

    setState(() {
      _permissionOk = true;
      _isOnline = true;
    });

    await _firebaseService.setDriverOnline(_driverId!, true);
    if (FirebaseAuth.instance.currentUser != null) {
      _startRequestListener();
    }

    _positionSubscription?.cancel();
    _positionSubscription = _locationService.getPositionStream().listen((
      Position position,
    ) async {
      final LatLng latLng = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentPosition = latLng;
          _currentHeading = position.heading;
        });
      }

      _mapController.move(latLng, _mapController.camera.zoom);

      await _firebaseService.updateDriverLocation(
        driverId: _driverId!,
        position: position,
        isOnline: true,
      );

      _filterRequestsByDistance();
    });
  }

  Future<void> _goOffline() async {
    if (_driverId == null) return;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await _requestsSubscription?.cancel();
    _requestsSubscription = null;

    setState(() {
      _isOnline = false;
      _allRequests = [];
      _nearbyRequests = [];
    });

    await _firebaseService.setDriverOnline(_driverId!, false);
  }

  void _startRequestListener() {
    _requestsSubscription?.cancel();
    _requestsSubscription = _rideRequestsRef.onValue.listen((event) {
      final Object? data = event.snapshot.value;
      final List<_RideRequest> requests = [];
      if (data is Map<dynamic, dynamic>) {
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final String status = (value['status'] ?? '').toString();
            if (status != 'searching') return;
            final Map<dynamic, dynamic>? rejectedBy =
                value['rejectedBy'] as Map<dynamic, dynamic>?;
            if (rejectedBy != null && _driverId != null) {
              if (rejectedBy[_driverId] == true) return;
            }
            final double pickupLat = (value['pickupLat'] ?? 0).toDouble();
            final double pickupLng = (value['pickupLng'] ?? 0).toDouble();
            final double dropLat = (value['dropLat'] ?? 0).toDouble();
            final double dropLng = (value['dropLng'] ?? 0).toDouble();
            requests.add(
              _RideRequest(
                id: key.toString(),
                pickupText: (value['pickupText'] ?? '').toString(),
                dropText: (value['dropText'] ?? '').toString(),
                pickup: LatLng(pickupLat, pickupLng),
                drop: LatLng(dropLat, dropLng),
                rideType: (value['rideType'] ?? '').toString(),
                fare: (value['fare'] ?? 0).toDouble(),
              ),
            );
          }
        });
      }

      _allRequests = requests;
      _filterRequestsByDistance();
    });
  }

  void _filterRequestsByDistance() {
    if (_currentPosition == null) return;
    final LatLng me = _currentPosition!;
    final List<_RideRequest> filtered = _allRequests.where((req) {
      final double distance = Geolocator.distanceBetween(
        me.latitude,
        me.longitude,
        req.pickup.latitude,
        req.pickup.longitude,
      );
      return distance <= _nearbyRadiusMeters;
    }).toList();
    if (mounted) {
      setState(() {
        _nearbyRequests = filtered;
      });
    }
  }

  Future<void> _acceptRequest(_RideRequest request) async {
    if (_driverId == null) return;
    final bool ok = await _rideRequestService.acceptRequest(
      requestId: request.id,
      driverId: _driverId!,
    );
    if (ok) {
      setState(() {
        _activeRequest = request;
        _activeStatus = 'accepted';
      });
    }
  }

  Future<void> _rejectRequest(_RideRequest request) async {
    if (_driverId == null) return;
    await _rideRequestService.rejectRequest(
      requestId: request.id,
      driverId: _driverId!,
    );
    setState(() {
      _nearbyRequests.removeWhere((r) => r.id == request.id);
    });
  }

  Future<void> _startRide() async {
    if (_activeRequest == null) return;
    await _rideRequestService.updateStatus(
      requestId: _activeRequest!.id,
      status: 'ongoing',
      assignedDriverId: _driverId,
    );
    setState(() {
      _activeStatus = 'ongoing';
    });
  }

  Future<void> _completeRide() async {
    if (_activeRequest == null) return;
    await _rideRequestService.updateStatus(
      requestId: _activeRequest!.id,
      status: 'completed',
      assignedDriverId: _driverId,
    );
    setState(() {
      _activeStatus = 'completed';
      _activeRequest = null;
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _requestsSubscription?.cancel();
    _authSubscription?.cancel();
    if (_isOnline && _driverId != null) {
      _firebaseService.setDriverOnline(_driverId!, false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng mapCenter = _currentPosition ?? AppConstants.defaultMapCenter;

    return Scaffold(
      appBar: AppBar(title: const Text('Driver Map')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_driverId == null)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Please sign in as a driver to go online.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                if (!_permissionOk)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Location permission required to go online.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _init,
                          child: const Text('Grant Permission'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      FlutterMap(
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
                          if (_currentPosition != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _currentPosition!,
                                  width: 48,
                                  height: 48,
                                  child: DriverMarker(
                                    position: _currentPosition!,
                                    heading: _currentHeading,
                                    isOnline: _isOnline,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (_isOnline && _activeRequest != null)
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active Ride',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _activeRequest!.pickupText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _activeRequest!.dropText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      '₹${_activeRequest!.fare.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_activeStatus == 'accepted')
                                      ElevatedButton(
                                        onPressed: _startRide,
                                        child: const Text('Start'),
                                      ),
                                    if (_activeStatus == 'ongoing')
                                      ElevatedButton(
                                        onPressed: _completeRide,
                                        child: const Text('Complete'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_isOnline &&
                          _activeRequest == null &&
                          _nearbyRequests.isNotEmpty)
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nearby Requests (${_nearbyRequests.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 140,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _nearbyRequests.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final req = _nearbyRequests[index];
                                      return Container(
                                        width: 220,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              req.pickupText,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              req.dropText,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const Spacer(),
                                            Row(
                                              children: [
                                                Text(
                                                  '₹${req.fare.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Spacer(),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      _acceptRequest(req),
                                                  child: const Text('Accept'),
                                                ),
                                                const SizedBox(width: 6),
                                                OutlinedButton(
                                                  onPressed: () =>
                                                      _rejectRequest(req),
                                                  child: const Text('Ignore'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _driverId == null
                ? null
                : _isOnline
                ? _goOffline
                : _goOnline,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isOnline ? Colors.red : Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              _isOnline ? 'Go Offline' : 'Go Online',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _RideRequest {
  final String id;
  final String pickupText;
  final String dropText;
  final LatLng pickup;
  final LatLng drop;
  final String rideType;
  final double fare;

  const _RideRequest({
    required this.id,
    required this.pickupText,
    required this.dropText,
    required this.pickup,
    required this.drop,
    required this.rideType,
    required this.fare,
  });
}
