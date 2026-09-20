import 'package:flutter_test/flutter_test.dart';
import 'package:mausam/data/models/weather_model.dart';
import 'package:mausam/engines/anomaly_detection_engine.dart';

void main() {
  group('WeatherAnomalyDetector Tests', () {
    test('Returns empty when daily forecast data is insufficient', () {
      const weather = WeatherModel(
        cityName: 'City',
        latitude: 10,
        longitude: 20,
        currentTemp: 25,
        feelsLike: 25,
        humidity: 50,
        windSpeed: 10,
        windDirection: 0,
        weatherCode: 0,
        precipitation: 0,
        precipitationProbability: 0,
        visibility: 10000,
        uvIndex: 5,
        dewPoint: 10,
        hourly: [],
        daily: [], // < 5 days
      );

      final anomalies = WeatherAnomalyDetector.detect(weather);
      expect(anomalies, isEmpty);
    });

    test('Detects temperature heat anomaly when current temp is far above baseline', () {
      final now = DateTime.now();
      // Baseline days around 20°C with small variance
      final daily = List.generate(10, (i) {
        return DailyWeather(
          date: now.add(Duration(days: i)),
          tempMin: 15.0,
          tempMax: 20.0 + (i % 2 == 0 ? 0.5 : -0.5),
          precipitationSum: 0.0,
          precipitationProbabilityMax: 0,
          windSpeedMax: 10.0,
          weatherCode: 1,
          sunrise: now,
          sunset: now,
          uvIndexMax: 5.0,
          et0FaoEvapotranspiration: 3.0,
          soilMoisture: 0.2,
        );
      });

      final weatherWithHeatwave = WeatherModel(
        cityName: 'Heat City',
        latitude: 10,
        longitude: 20,
        currentTemp: 38.0, // Far above 20°C
        feelsLike: 40,
        humidity: 40,
        windSpeed: 10,
        windDirection: 0,
        weatherCode: 0,
        precipitation: 0,
        precipitationProbability: 0,
        visibility: 10000,
        uvIndex: 8,
        dewPoint: 12,
        hourly: [],
        daily: daily,
      );

      final anomalies = WeatherAnomalyDetector.detect(weatherWithHeatwave);
      expect(anomalies, isNotEmpty);
      final tempAnomaly = anomalies.firstWhere((a) => a.metric == 'Temperature');
      expect(tempAnomaly.isAboveAverage, isTrue);
      expect(tempAnomaly.zScore, greaterThan(2.0));
    });
  });
}
