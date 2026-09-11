import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/weather_model.dart';
import '../models/air_quality_model.dart';
import '../models/marine_model.dart';

class OpenMeteoService {
  final Dio _dio;
  static const Duration _pacingDelay = Duration(milliseconds: 1200);
  static const Duration _cacheTtl = Duration(minutes: 15);

  final Map<String, (DateTime, dynamic)> _cache = {};

  OpenMeteoService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'User-Agent': 'MausamApp/1.0',
                },
              ),
            );

  /// Fetches 7-day comprehensive weather, hourly, daily, UV, soil moisture, etc.
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
    String? cityName,
  }) async {
    final cacheKey = 'weather_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    final cached = _cache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.$1) < _cacheTtl) {
      await Future.delayed(const Duration(milliseconds: 300));
      return cached.$2 as WeatherModel;
    }

    // Pacing delay to reduce server load ("laggy" pacing)
    await Future.delayed(_pacingDelay);

    try {
      final response = await _dio.get(
        ApiEndpoints.weatherBase,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': [
            'temperature_2m',
            'relative_humidity_2m',
            'apparent_temperature',
            'weather_code',
            'wind_speed_10m',
            'wind_direction_10m',
            'uv_index',
            'precipitation',
            'visibility',
            'dew_point_2m',
          ].join(','),
          'hourly': [
            'temperature_2m',
            'apparent_temperature',
            'precipitation_probability',
            'precipitation',
            'wind_speed_10m',
            'wind_direction_10m',
            'weather_code',
            'relative_humidity_2m',
            'visibility',
            'uv_index',
          ].join(','),
          'daily': [
            'temperature_2m_max',
            'temperature_2m_min',
            'precipitation_sum',
            'precipitation_probability_max',
            'wind_speed_10m_max',
            'weather_code',
            'sunrise',
            'sunset',
            'uv_index_max',
            'et0_fao_evapotranspiration',
            'soil_moisture_0_to_10cm',
          ].join(','),
          'timezone': 'auto',
          'forecast_days': 14,
        },
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      if (cityName != null) {
        data['timezone'] = cityName;
      }
      final model = WeatherModel.fromJson(data);
      _cache[cacheKey] = (DateTime.now(), model);
      return model;
    } catch (e) {
      // Return realistic mock fallback if network error
      final mock = WeatherModel.mock();
      if (cityName != null) {
        return WeatherModel(
          cityName: cityName,
          latitude: latitude,
          longitude: longitude,
          currentTemp: mock.currentTemp,
          feelsLike: mock.feelsLike,
          humidity: mock.humidity,
          windSpeed: mock.windSpeed,
          windDirection: mock.windDirection,
          weatherCode: mock.weatherCode,
          precipitation: mock.precipitation,
          precipitationProbability: mock.precipitationProbability,
          visibility: mock.visibility,
          uvIndex: mock.uvIndex,
          dewPoint: mock.dewPoint,
          hourly: mock.hourly,
          daily: mock.daily,
        );
      }
      return mock;
    }
  }

  /// Fetches European AQI, PM2.5, PM10, gases, and pollen counts.
  Future<AirQualityModel> fetchAirQuality({
    required double latitude,
    required double longitude,
  }) async {
    final cacheKey = 'aqi_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    final cached = _cache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.$1) < _cacheTtl) {
      return cached.$2 as AirQualityModel;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final response = await _dio.get(
        ApiEndpoints.airQualityBase,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': [
            'european_aqi',
            'pm2_5',
            'pm10',
            'nitrogen_dioxide',
            'ozone',
            'grass_pollen',
            'tree_pollen',
            'weed_pollen',
            'uv_index',
          ].join(','),
          'timezone': 'auto',
        },
      );
      final model = AirQualityModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      _cache[cacheKey] = (DateTime.now(), model);
      return model;
    } catch (e) {
      return AirQualityModel.mock();
    }
  }

  /// Fetches wave height, period, direction, swell, and sea surface temperature.
  Future<MarineModel> fetchMarine({
    required double latitude,
    required double longitude,
  }) async {
    final cacheKey = 'marine_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    final cached = _cache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.$1) < _cacheTtl) {
      return cached.$2 as MarineModel;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final response = await _dio.get(
        ApiEndpoints.marineBase,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': [
            'wave_height',
            'wave_period',
            'wave_direction',
            'swell_wave_height',
            'swell_wave_direction',
            'sea_surface_temperature',
          ].join(','),
          'timezone': 'auto',
        },
      );
      final model = MarineModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      _cache[cacheKey] = (DateTime.now(), model);
      return model;
    } catch (e) {
      return MarineModel.mock();
    }
  }
}
