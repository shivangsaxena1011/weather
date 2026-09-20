import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/weather_model.dart';
import '../models/air_quality_model.dart';
import '../models/marine_model.dart';
import '../../core/errors/weather_exceptions.dart';

class OpenMeteoService {
  final Dio _dio;
  final String? _apiKey;
  static const Duration _cacheTtl = Duration(minutes: 5);

  final Map<String, (DateTime, dynamic)> _cache = {};

  OpenMeteoService({Dio? dio, String? apiKey})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'User-Agent': 'MausamApp/1.0',
                },
              ),
            ),
        _apiKey = apiKey ?? (dotenv.isInitialized ? dotenv.env['OPEN_METEO_API_KEY'] : null);

  Map<String, dynamic> _withApiKey(Map<String, dynamic> params) {
    if (_apiKey != null && _apiKey!.trim().isNotEmpty) {
      params['apikey'] = _apiKey!.trim();
    }
    return params;
  }

  /// Fetches 7-day comprehensive weather, hourly, daily, UV, soil moisture, etc.
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
    String? cityName,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'weather_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    final cached = _cache[cacheKey];
    if (!forceRefresh && cached != null && DateTime.now().difference(cached.$1) < _cacheTtl) {
      return cached.$2 as WeatherModel;
    }

    try {
      final response = await _dio.get(
        ApiEndpoints.weatherBase,
        queryParameters: _withApiKey({
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
            'soil_moisture_0_to_10cm',
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
          ].join(','),
          'timezone': 'auto',
          'forecast_days': 14,
        }),
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      if (cityName != null) {
        data['timezone'] = cityName;
      }
      final model = WeatherModel.fromJson(data);
      _cache[cacheKey] = (DateTime.now(), model);
      return model;
    } catch (e) {
      _handleError(e);
    }
  }

  /// Fetches European AQI, PM2.5, PM10, gases, and pollen counts.
  Future<AirQualityModel> fetchAirQuality({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'aqi_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    final cached = _cache[cacheKey];
    if (!forceRefresh && cached != null && DateTime.now().difference(cached.$1) < _cacheTtl) {
      return cached.$2 as AirQualityModel;
    }

    try {
      final response = await _dio.get(
        ApiEndpoints.airQualityBase,
        queryParameters: _withApiKey({
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
        }),
      );
      final model = AirQualityModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      _cache[cacheKey] = (DateTime.now(), model);
      return model;
    } catch (e) {
      _handleError(e);
    }
  }

  /// Fetches wave height, period, direction, swell, and sea surface temperature.
  Future<MarineModel> fetchMarine({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'marine_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    final cached = _cache[cacheKey];
    if (!forceRefresh && cached != null && DateTime.now().difference(cached.$1) < _cacheTtl) {
      return cached.$2 as MarineModel;
    }

    try {
      final response = await _dio.get(
        ApiEndpoints.marineBase,
        queryParameters: _withApiKey({
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
        }),
      );
      final model = MarineModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      _cache[cacheKey] = (DateTime.now(), model);
      return model;
    } catch (e) {
      _handleError(e);
    }
  }

  /// Fetches historical daily weather records from Open-Meteo Archive API.
  Future<List<DailyWeather>> fetchHistoricalDaily({
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(endDate);
    final cacheKey =
        'hist_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_${startStr}_$endStr';
    final cached = _cache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.$1) < _cacheTtl) {
      return cached.$2 as List<DailyWeather>;
    }

    try {
      final response = await _dio.get(
        ApiEndpoints.archiveBase,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'start_date': startStr,
          'end_date': endStr,
          'daily': [
            'temperature_2m_max',
            'temperature_2m_min',
            'precipitation_sum',
            'wind_speed_10m_max',
            'weather_code',
          ].join(','),
          'timezone': 'auto',
        },
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      final dailyRaw = data['daily'] as Map<String, dynamic>? ?? {};
      final times = (dailyRaw['time'] as List<dynamic>? ?? []).cast<String>();

      final list = List.generate(times.length, (i) {
        final date = DateTime.parse(times[i]);
        return DailyWeather(
          date: date,
          tempMin: (dailyRaw['temperature_2m_min']?[i] as num? ?? 0).toDouble(),
          tempMax: (dailyRaw['temperature_2m_max']?[i] as num? ?? 0).toDouble(),
          precipitationSum:
              (dailyRaw['precipitation_sum']?[i] as num? ?? 0).toDouble(),
          precipitationProbabilityMax: 0,
          windSpeedMax:
              (dailyRaw['wind_speed_10m_max']?[i] as num? ?? 0).toDouble(),
          weatherCode: (dailyRaw['weather_code']?[i] as num? ?? 0).toInt(),
          sunrise: DateTime(date.year, date.month, date.day, 6, 0),
          sunset: DateTime(date.year, date.month, date.day, 18, 0),
          uvIndexMax: 5.0,
          et0FaoEvapotranspiration: 3.5,
          soilMoisture: 30.0,
        );
      });

      _cache[cacheKey] = (DateTime.now(), list);
      return list;
    } catch (e) {
      _handleError(e);
    }
  }

  Never _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          throw NetworkError(
            message: 'Weather service connection timed out. Please check network connectivity.',
            technicalDetails: error.toString(),
          );
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode ?? 500;
          if (code == 429) {
            throw RateLimitError(
              message: 'Rate limit reached on Open-Meteo. Please wait a moment.',
              technicalDetails: error.toString(),
            );
          }
          throw WeatherAPIError(
            statusCode: code,
            message: 'Weather API returned HTTP status $code.',
            technicalDetails: error.toString(),
          );
        case DioExceptionType.cancel:
          throw const NetworkError(message: 'Weather request was cancelled.');
        default:
          throw NetworkError(
            message: 'Network communication failure: ${error.message}',
            technicalDetails: error.toString(),
          );
      }
    }
    if (error is WeatherAppException) {
      throw error;
    }
    throw WeatherAPIError(
      message: 'Failed to process meteorological data: $error',
      technicalDetails: error.toString(),
    );
  }
}
