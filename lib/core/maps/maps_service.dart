import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapsService {
  static const _nominatimBase = 'https://nominatim.openstreetmap.org';
  static const _headers = {'User-Agent': 'WakaApp/1.0 (abuja navigation)'};

  Future<LatLng?> geocode(String query) async {
    var result = await _tryGeocode(query);
    if (result != null) return result;

    final simplified = '${query.split(',').first.trim()}, Abuja';
    result = await _tryGeocode(simplified);
    if (result != null) return result;

    final bare = '${query.split(',').first.trim()}, FCT Nigeria';
    return _tryGeocode(bare);
  }

  Future<LatLng?> _tryGeocode(String query) async {
    final uri = Uri.parse('$_nominatimBase/search').replace(
      queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '1',
        'countrycodes': 'ng',
      },
    );
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      return null;
    }

    final results = jsonDecode(response.body) as List<dynamic>;
    if (results.isEmpty) return null;

    final first = results.first as Map<String, dynamic>;
    return LatLng(
      double.parse(first['lat'] as String),
      double.parse(first['lon'] as String),
    );
  }

  Future<List<LatLng>> geocodeStops(List<String> queries) async {
    final results = <LatLng>[];

    for (final query in queries) {
      final coords = await geocode(query);
      if (coords != null) results.add(coords);
      // Nominatim rate limit is 1 req/sec
      await Future.delayed(const Duration(seconds: 1));
    }

    return results;
  }

  LatLng midpoint(LatLng a, LatLng b) {
    return LatLng(
      (a.latitude + b.latitude) / 2,
      (a.longitude + b.longitude) / 2,
    );
  }

  double boundingZoom(LatLng origin, LatLng destination) {
    final latDiff = (origin.latitude - destination.latitude).abs();
    final lngDiff = (origin.longitude - destination.longitude).abs();
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    if (maxDiff < 0.01) return 15;
    if (maxDiff < 0.05) return 13;
    if (maxDiff < 0.1) return 12;
    if (maxDiff < 0.5) return 11;
    return 10;
  }

  Future<List<LatLng>> getRoadGeometry(
    LatLng origin,
    LatLng destination,
  ) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) return [origin, destination];

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) return [origin, destination];

    final coords = routes.first['geometry']['coordinates'] as List<dynamic>;
    return coords.map((c) {
      final point = c as List<dynamic>;
      return LatLng((point[1] as num).toDouble(), (point[0] as num).toDouble());
    }).toList();
  }
}
