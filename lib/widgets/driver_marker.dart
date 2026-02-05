import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class DriverMarker extends StatelessWidget {
  final LatLng position;
  final double heading;
  final bool isOnline;
  final double size;

  const DriverMarker({
    super.key,
    required this.position,
    required this.heading,
    required this.isOnline,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isOnline ? Colors.green : Colors.grey;

    return Transform.rotate(
      angle: heading * (math.pi / 180),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(
          Icons.navigation,
          color: color,
          size: size * 0.6,
        ),
      ),
    );
  }
}
