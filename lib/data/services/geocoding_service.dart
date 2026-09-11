import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/location_model.dart';

class GeocodingService {
  final Dio _dio;
  static const Duration _pacingDelay = Duration(milliseconds: 1000);
  final Map<String, (DateTime, dynamic)> _cache = {};

  GeocodingService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
                headers: {
                  'User-Agent': 'MausamApp/1.0 (contact@mausam.app)',
                },
              ),
            );

  /// Reverse geocodes latitude/longitude to a readable city and country.
  Future<LocationModel> reverseGeocode(double lat, double lon) async {
    final key = 'rev_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';
    final cached = _cache[key];
    if (cached != null && DateTime.now().difference(cached.$1).inMinutes < 60) {
      return cached.$2 as LocationModel;
    }

    await Future.delayed(_pacingDelay);

    try {
      final response = await _dio.get(
        ApiEndpoints.nominatimReverse,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'format': 'json',
          'zoom': 10,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>? ?? {};

      final city = address['city'] ??
          address['town'] ??
          address['village'] ??
          address['municipality'] ??
          address['county'] ??
          'Unknown Location';

      final country = address['country'] ?? '';
      final state = address['state'] as String?;

      final loc = LocationModel(
        latitude: lat,
        longitude: lon,
        cityName: city.toString(),
        country: country.toString(),
        state: state,
      );
      _cache[key] = (DateTime.now(), loc);
      return loc;
    } catch (_) {
      return LocationModel(
        latitude: lat,
        longitude: lon,
        cityName: 'My Location',
        country: '',
      );
    }
  }

  /// Searches cities using Open-Meteo's free geocoding API.
  Future<List<LocationModel>> searchCity(String query) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return [];

    final cacheKey = 'search_$clean';
    final cached = _cache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.$1).inMinutes < 60) {
      return cached.$2 as List<LocationModel>;
    }

    await Future.delayed(_pacingDelay);

    try {
      final response = await _dio.get(
        ApiEndpoints.geocodingBase,
        queryParameters: {
          'name': query.trim(),
          'count': 5,
          'language': 'en',
          'format': 'json',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      final list = results.map((item) {
        final map = item as Map<String, dynamic>;
        return LocationModel(
          latitude: (map['latitude'] as num).toDouble(),
          longitude: (map['longitude'] as num).toDouble(),
          cityName: map['name'] as String? ?? 'Unknown',
          country: map['country'] as String? ?? '',
          state: map['admin1'] as String?,
        );
      }).toList();

      _cache[cacheKey] = (DateTime.now(), list);
      return list;
    } catch (_) {
      return [];
    }
  }
}
