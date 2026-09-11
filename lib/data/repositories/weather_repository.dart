import '../models/weather_model.dart';
import '../models/air_quality_model.dart';
import '../models/marine_model.dart';
import '../services/open_meteo_service.dart';

class WeatherRepository {
  final OpenMeteoService _service;

  WeatherRepository({OpenMeteoService? service})
      : _service = service ?? OpenMeteoService();

  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
    String? cityName,
  }) async {
    return _service.fetchWeather(
      latitude: latitude,
      longitude: longitude,
      cityName: cityName,
    );
  }

  Future<AirQualityModel> getAirQuality({
    required double latitude,
    required double longitude,
  }) async {
    return _service.fetchAirQuality(
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<MarineModel> getMarine({
    required double latitude,
    required double longitude,
  }) async {
    return _service.fetchMarine(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
