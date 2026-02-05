import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  static const String _baseUrl =
      'https://router.project-osrm.org/route/v1/driving';

  Future<List<LatLng>> fetchRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    final String coords =
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
    final Uri uri = Uri.parse('$_baseUrl/$coords').replace(
      queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
      },
    );

    final http.Response response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'User-Agent': 'rapido_ui_app/1.0 (contact: dev@rapido.app)',
    });

    if (response.statusCode != 200) {
      return [];
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic>? routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      return [];
    }

    final Map<String, dynamic> route = routes.first as Map<String, dynamic>;
    final Map<String, dynamic>? geometry =
        route['geometry'] as Map<String, dynamic>?;
    if (geometry == null) return [];

    final List<dynamic>? coordinates = geometry['coordinates'] as List<dynamic>?;
    if (coordinates == null) return [];

    return coordinates.map((dynamic item) {
      final List<dynamic> pair = item as List<dynamic>;
      final double lng = (pair[0] as num).toDouble();
      final double lat = (pair[1] as num).toDouble();
      return LatLng(lat, lng);
    }).toList();
  }
}
