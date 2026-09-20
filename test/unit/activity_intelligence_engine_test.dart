import 'package:flutter_test/flutter_test.dart';
import 'package:mausam/data/models/weather_model.dart';
import 'package:mausam/data/models/air_quality_model.dart';
import 'package:mausam/engines/activity_intelligence_engine.dart';

WeatherModel createCustomWeather({
  double temp = 22.0,
  double feelsLike = 22.0,
  double humidity = 50.0,
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

AirQualityModel createCustomAQI({int aqi = 30}) {
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
  group('ActivityRecommendationEngine Tests', () {
    test('Evaluates all 10 core activities', () {
      final weather = createCustomWeather();
      final aqi = createCustomAQI();

      final activities = ActivityRecommendationEngine.evaluateAll(
        weather: weather,
        airQuality: aqi,
      );

      expect(activities.length, 10);
      expect(
        activities.map((a) => a.category).toSet(),
        containsAll([
          ActivityCategory.running,
          ActivityCategory.cycling,
          ActivityCategory.walking,
          ActivityCategory.gym,
          ActivityCategory.outdoorSports,
          ActivityCategory.photography,
          ActivityCategory.hiking,
          ActivityCategory.outdoorEvents,
          ActivityCategory.travel,
          ActivityCategory.commuting,
        ]),
      );
    });

    test('Ideal conditions yield high running and cycling scores', () {
      final weather = createCustomWeather(
        temp: 18.0,
        feelsLike: 18.0,
        humidity: 50.0,
        windSpeed: 8.0,
        precipProb: 0.0,
      );
      final aqi = createCustomAQI(aqi: 25);

      final activities = ActivityRecommendationEngine.evaluateAll(
        weather: weather,
        airQuality: aqi,
      );

      final running = activities.firstWhere((a) => a.category == ActivityCategory.running);
      expect(running.score, greaterThanOrEqualTo(80));
      expect(running.status, anyOf(contains('Ideal'), contains('Good'), contains('Great'), contains('Excellent')));
    });

    test('Severe rain drops outdoor sports and warns about weather', () {
      final weather = createCustomWeather(
        temp: 16.0,
        feelsLike: 15.0,
        humidity: 95.0,
        windSpeed: 45.0,
        precipProb: 90.0,
        precip: 15.0,
        code: 95, // Thunderstorm
      );
      final aqi = createCustomAQI(aqi: 40);

      final activities = ActivityRecommendationEngine.evaluateAll(
        weather: weather,
        airQuality: aqi,
      );

      final sports = activities.firstWhere((a) => a.category == ActivityCategory.outdoorSports);
      expect(sports.score, lessThan(60));
      expect(sports.warnings, isNotEmpty);

      // Indoor Gym should remain viable or recommended
      final gym = activities.firstWhere((a) => a.category == ActivityCategory.gym);
      expect(gym.score, greaterThan(70));
    });
  });
}
