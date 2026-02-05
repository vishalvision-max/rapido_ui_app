import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

class PlaceSearchResult {
  final String displayName;
  final LatLng location;

  const PlaceSearchResult({
    required this.displayName,
    required this.location,
  });
}

class PlaceSearchService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  Future<List<PlaceSearchResult>> search(
    String query, {
    LatLng? near,
    double radiusKm = 5,
  }) async {
    final String q = query.trim();
    if (q.isEmpty) return [];

    final Map<String, String> params = {
      'q': q,
      'format': 'json',
      'limit': '5',
      'addressdetails': '0',
    };

    if (near != null) {
      final double deltaLat = radiusKm / 110.574;
      final double deltaLng =
          radiusKm / (111.320 * math.cos(near.latitude * math.pi / 180));
      final double left = near.longitude - deltaLng;
      final double right = near.longitude + deltaLng;
      final double top = near.latitude + deltaLat;
      final double bottom = near.latitude - deltaLat;
      params.addAll({
        'viewbox': '$left,$top,$right,$bottom',
        'bounded': '1',
      });
    }

    final Uri uri = Uri.parse(_baseUrl).replace(queryParameters: params);

    final http.Response response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'rapido_ui_app/1.0 (contact: dev@rapido.app)',
      },
    );

    if (response.statusCode != 200) {
      return [];
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((dynamic item) {
      final Map<String, dynamic> json = item as Map<String, dynamic>;
      final double lat = double.tryParse(json['lat'] as String? ?? '') ?? 0;
      final double lng = double.tryParse(json['lon'] as String? ?? '') ?? 0;
      return PlaceSearchResult(
        displayName: json['display_name'] as String? ?? 'Unknown',
        location: LatLng(lat, lng),
      );
    }).toList();
  }
}
