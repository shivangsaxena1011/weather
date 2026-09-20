import 'package:flutter_test/flutter_test.dart';
import 'package:mausam/data/models/weather_model.dart';
import 'package:mausam/data/models/air_quality_model.dart';
import 'package:mausam/engines/comfort_score_engine.dart';

WeatherModel createCustomWeather({
  double temp = 22.0,
  double feelsLike = 22.0,
  double humidity = 45.0,
  double windSpeed = 10.0,
  double precipProb = 0.0,
  double precip = 0.0,
  double uv = 3.0,
  int code = 0,
}) {
  return WeatherModel(
    cityName: 'Test City',
    latitude: 20.0,
    longitude: 70.0,
    currentTemp: temp,
    feelsLike: feelsLike,
    humidity: humidity,
    windSpeed: windSpeed,
    windDirection: 180.0,
    weatherCode: code,
    precipitation: precip,
    precipitationProbability: precipProb,
    visibility: 10000.0,
    uvIndex: uv,
    dewPoint: 12.0,
    hourly: [],
    daily: [],
  );
}

AirQualityModel createCustomAQI({int aqi = 25}) {
  return AirQualityModel(
    aqi: aqi,
    pm25: 10.0,
    pm10: 20.0,
    no2: 15.0,
    o3: 30.0,
    grassPollen: 10.0,
    treePollen: 5.0,
    weedPollen: 10.0,
    uvIndex: 3.0,
  );
}

void main() {
  group('ComfortScoreEngine Tests', () {
    test('Calculates high score for ideal conditions', () {
      final weather = createCustomWeather(
        temp: 22.0,
        feelsLike: 22.0,
        humidity: 45.0,
        windSpeed: 8.0,
        precipProb: 0.0,
        precip: 0.0,
        uv: 2.0,
      );
      final aqi = createCustomAQI(aqi: 20);

      final result = ComfortScoreEngine.calculate(
        weather: weather,
        airQuality: aqi,
      );

      expect(result.overallScore, greaterThanOrEqualTo(80));
      expect(result.temperatureScore, greaterThanOrEqualTo(85));
      expect(result.rainScore, greaterThanOrEqualTo(90));
      expect(result.aqiScore, greaterThanOrEqualTo(85));
    });

    test('Calculates lower score and detects harsh conditions', () {
      final weather = createCustomWeather(
        temp: 42.0,
        feelsLike: 45.0,
        humidity: 85.0,
        windSpeed: 35.0,
        precipProb: 80.0,
        precip: 12.0,
        uv: 11.0,
        code: 95,
      );
      final aqi = createCustomAQI(aqi: 220);

      final result = ComfortScoreEngine.calculate(
        weather: weather,
        airQuality: aqi,
      );

      expect(result.overallScore, lessThanOrEqualTo(45));
      expect(result.label, isNotEmpty);
      expect(result.primaryFactor, isNotEmpty);
    });

    test('Identifies rain as primary factor when precip probability is high', () {
      final weather = createCustomWeather(
        temp: 21.0,
        feelsLike: 21.0,
        humidity: 50.0,
        windSpeed: 10.0,
        precipProb: 95.0,
        precip: 18.0,
        uv: 2.0,
      );
      final aqi = createCustomAQI(aqi: 30);

      final result = ComfortScoreEngine.calculate(
        weather: weather,
        airQuality: aqi,
      );

      expect(result.rainScore, lessThanOrEqualTo(30));
      expect(result.primaryFactor.toLowerCase(), contains('rain'));
    });

    test('Overall score is clamped between 0 and 100', () {
      final extremeCold = createCustomWeather(
        temp: -30.0,
        feelsLike: -45.0,
        humidity: 95.0,
        windSpeed: 80.0,
        precipProb: 100.0,
        precip: 30.0,
        uv: 15.0,
      );
      final severeAqi = createCustomAQI(aqi: 500);

      final result = ComfortScoreEngine.calculate(
        weather: extremeCold,
        airQuality: severeAqi,
      );

      expect(result.overallScore, inInclusiveRange(0, 100));
    });
  });
}
