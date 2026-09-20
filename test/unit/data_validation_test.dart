import 'package:flutter_test/flutter_test.dart';
import 'package:mausam/data/models/weather_model.dart';
import 'package:mausam/data/models/air_quality_model.dart';

void main() {
  group('WeatherModel Data Validation & Clamping Tests', () {
    test('Clamps out-of-bounds geographic coordinates', () {
      final json = {
        'latitude': 120.0, // Invalid: exceeds 90
        'longitude': -220.0, // Invalid: below -180
        'utc_offset_seconds': 19800,
        'timezone': 'Asia/Kolkata',
        'current': {
          'temperature_2m': 25.0,
          'apparent_temperature': 26.0,
          'relative_humidity_2m': 60,
          'wind_speed_10m': 10.0,
          'wind_direction_10m': 180,
          'surface_pressure': 1012.0,
          'precipitation_probability': 20,
          'uv_index': 5.0,
          'weather_code': 1,
          'visibility': 10000.0,
          'dew_point_2m': 16.0,
        },
      };

      final model = WeatherModel.fromJson(json, cityName: 'Test City');
      expect(model.latitude, equals(90.0));
      expect(model.longitude, equals(-180.0));
      expect(model.utcOffsetSeconds, equals(19800));
      expect(model.timezoneName, equals('Asia/Kolkata'));
    });

    test('Clamps extreme temperature anomalies into safe meteorological bounds', () {
      final json = {
        'latitude': 28.61,
        'longitude': 77.20,
        'current': {
          'temperature_2m': 120.0, // Anomaly: Clamped to 60.0
          'apparent_temperature': -120.0, // Anomaly: Clamped to -90.0
          'relative_humidity_2m': 150, // Clamped to 100.0
          'wind_speed_10m': 450.0, // Clamped to 350.0
          'wind_direction_10m': 400, // Clamped to 360.0
          'precipitation_probability': 120, // Clamped to 100.0
          'uv_index': 30.0, // Clamped to 25.0
          'weather_code': 0,
        },
      };

      final model = WeatherModel.fromJson(json, cityName: 'Delhi');
      expect(model.currentTemp, equals(60.0));
      expect(model.feelsLike, equals(-90.0));
      expect(model.humidity, equals(100.0));
      expect(model.windSpeed, equals(350.0));
      expect(model.windDirection, equals(360.0));
      expect(model.precipitationProbability, equals(100.0));
      expect(model.uvIndex, equals(25.0));
    });

    test('Clamps negative values that must be strictly non-negative', () {
      final json = {
        'latitude': 10.0,
        'longitude': 20.0,
        'current': {
          'temperature_2m': 20.0,
          'relative_humidity_2m': -15, // Clamped to 0.0
          'wind_speed_10m': -5.0, // Clamped to 0.0
          'wind_direction_10m': -30, // Clamped to 0.0
          'precipitation_probability': -10, // Clamped to 0.0
          'uv_index': -2.0, // Clamped to 0.0
          'visibility': -500.0, // Clamped to 0.0
          'weather_code': 0,
        },
      };

      final model = WeatherModel.fromJson(json, cityName: 'Test');
      expect(model.humidity, equals(0.0));
      expect(model.windSpeed, equals(0.0));
      expect(model.windDirection, equals(0.0));
      expect(model.precipitationProbability, equals(0.0));
      expect(model.uvIndex, equals(0.0));
      expect(model.visibility, equals(0.0));
    });
  });

  group('AirQualityModel Data Validation Tests', () {
    test('Clamps negative pollutant values to zero', () {
      final json = {
        'current': {
          'european_aqi': -10,
          'pm2_5': -5.0,
          'pm10': -8.0,
          'nitrogen_dioxide': -1.2,
          'ozone': -3.4,
          'uv_index': -1.0,
          'alder_pollen': -2.0,
          'birch_pollen': -0.5,
          'grass_pollen': -10.0,
          'mugwort_pollen': -4.0,
          'olive_pollen': -1.0,
          'ragweed_pollen': -0.2,
        },
      };

      final aqi = AirQualityModel.fromJson(json);
      expect(aqi.aqi, equals(0));
      expect(aqi.pm25, equals(0.0));
      expect(aqi.pm10, equals(0.0));
      expect(aqi.no2, equals(0.0));
      expect(aqi.o3, equals(0.0));
      expect(aqi.uvIndex, equals(0.0));
      expect(aqi.grassPollen, equals(0.0));
    });

    test('Parses typical air quality data accurately', () {
      final json = {
        'current': {
          'european_aqi': 42,
          'pm2_5': 12.5,
          'pm10': 25.0,
          'nitrogen_dioxide': 18.2,
          'ozone': 45.0,
          'uv_index': 4.5,
          'grass_pollen': 15.0,
          'birch_pollen': 8.0,
          'ragweed_pollen': 2.0,
        },
      };

      final aqi = AirQualityModel.fromJson(json);
      expect(aqi.aqi, equals(42));
      expect(aqi.pm25, equals(12.5));
      expect(aqi.pm10, equals(25.0));
      expect(aqi.no2, equals(18.2));
      expect(aqi.o3, equals(45.0));
      expect(aqi.uvIndex, equals(4.5));
      expect(aqi.grassPollen, equals(15.0));
      expect(aqi.treePollen, equals(8.0));
      expect(aqi.weedPollen, equals(2.0));
    });
  });
}
