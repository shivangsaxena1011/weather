import '../models/weather_model.dart';
import '../models/air_quality_model.dart';
import '../models/marine_model.dart';
import '../services/open_meteo_service.dart';

/// Abstract WeatherRepository defining interface for weather providers.
abstract class WeatherRepository {
  factory WeatherRepository({OpenMeteoService? service}) =
      OpenMeteoWeatherRepository;

  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
    String? cityName,
    bool forceRefresh = false,
  });

  Future<AirQualityModel> getAirQuality({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  });

  Future<MarineModel> getMarine({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  });

  Future<List<DailyWeather>> getHistoricalDailyWeather({
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
  });
}

/// Open-Meteo implementation of WeatherRepository.
class OpenMeteoWeatherRepository implements WeatherRepository {
  final OpenMeteoService _service;

  OpenMeteoWeatherRepository({OpenMeteoService? service})
      : _service = service ?? OpenMeteoService();

  @override
  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
    String? cityName,
    bool forceRefresh = false,
  }) {
    return _service.fetchWeather(
      latitude: latitude,
      longitude: longitude,
      cityName: cityName,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<AirQualityModel> getAirQuality({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) {
    return _service.fetchAirQuality(
      latitude: latitude,
      longitude: longitude,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<MarineModel> getMarine({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) {
    return _service.fetchMarine(
      latitude: latitude,
      longitude: longitude,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<List<DailyWeather>> getHistoricalDailyWeather({
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _service.fetchHistoricalDaily(
      latitude: latitude,
      longitude: longitude,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
