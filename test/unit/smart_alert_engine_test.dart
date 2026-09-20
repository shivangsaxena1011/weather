import 'package:flutter_test/flutter_test.dart';
import 'package:mausam/data/models/weather_model.dart';
import 'package:mausam/data/models/air_quality_model.dart';
import 'package:mausam/engines/smart_alert_engine.dart';
import 'package:mausam/widgets/common/alert_banner.dart';

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
    cityName: 'Alert Test City',
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

AirQualityModel createCustomAQI({int aqi = 30, double pm25 = 10.0}) {
  return AirQualityModel(
    aqi: aqi,
    pm25: pm25,
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
  group('SmartAlertEngine Tests', () {
    test('Detects severe thunderstorm alert', () {
      final weather = createCustomWeather(code: 95);
      final aqi = createCustomAQI();

      final alerts = SmartAlertEngine.evaluate(
        weather: weather,
        airQuality: aqi,
      );

      expect(alerts.any((a) => a.id == 'severe_storm'), isTrue);
      final stormAlert = alerts.firstWhere((a) => a.id == 'severe_storm');
      expect(stormAlert.severity, AlertSeverity.danger);
    });

    test('Detects extreme heat warning', () {
      final weather = createCustomWeather(temp: 41.0, feelsLike: 45.0);
      final aqi = createCustomAQI();

      final alerts = SmartAlertEngine.evaluate(
        weather: weather,
        airQuality: aqi,
      );

      expect(alerts.any((a) => a.id == 'extreme_heat'), isTrue);
    });

    test('Detects hazardous AQI and respects user preference toggle', () {
      final weather = createCustomWeather();
      final badAqi = createCustomAQI(aqi: 180, pm25: 85.0);

      // With default preferences (aqi enabled)
      final alertsEnabled = SmartAlertEngine.evaluate(
        weather: weather,
        airQuality: badAqi,
      );
      expect(alertsEnabled.any((a) => a.id == 'poor_aqi'), isTrue);

      // With aqi disabled by user
      final alertsDisabled = SmartAlertEngine.evaluate(
        weather: weather,
        airQuality: badAqi,
        preferences: {'aqi': false},
      );
      expect(alertsDisabled.any((a) => a.id == 'poor_aqi'), isFalse);
    });

    test('Detects UV warning when UV is extreme', () {
      final weather = createCustomWeather(uv: 9.5);
      final aqi = createCustomAQI();

      final alerts = SmartAlertEngine.evaluate(
        weather: weather,
        airQuality: aqi,
      );

      expect(alerts.any((a) => a.id == 'high_uv'), isTrue);
    });
  });
}
