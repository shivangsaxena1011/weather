import 'package:flutter/material.dart';
import '../data/models/weather_model.dart';
import '../data/models/air_quality_model.dart';

class ComfortScoreResult {
  final int overallScore;
  final int temperatureScore;
  final int humidityScore;
  final int windScore;
  final int rainScore;
  final int uvScore;
  final int aqiScore;
  final String label;
  final String summary;
  final String primaryFactor;

  const ComfortScoreResult({
    required this.overallScore,
    required this.temperatureScore,
    required this.humidityScore,
    required this.windScore,
    required this.rainScore,
    required this.uvScore,
    required this.aqiScore,
    required this.label,
    required this.summary,
    required this.primaryFactor,
  });

  Color get color {
    if (overallScore >= 80) return const Color(0xFF10B981); // Emerald Green
    if (overallScore >= 65) return const Color(0xFF06B6D4); // Cyan
    if (overallScore >= 50) return const Color(0xFFF59E0B); // Amber
    if (overallScore >= 35) return const Color(0xFFF97316); // Orange
    return const Color(0xFFEF4444); // Red
  }
}

class ComfortScoreEngine {
  const ComfortScoreEngine();

  static ComfortScoreResult calculate({
    required WeatherModel weather,
    required AirQualityModel airQuality,
  }) {
    final tempScore = _calculateTempScore(weather.feelsLike);
    final humidScore = _calculateHumidityScore(weather.humidity, weather.feelsLike);
    final windScore = _calculateWindScore(weather.windSpeed);
    final rainScore = _calculateRainScore(weather.precipitationProbability, weather.precipitation);
    final uvScore = _calculateUvScore(weather.uvIndex);
    final aqiScore = _calculateAqiScore(airQuality.aqi);

    // Weighted overall score:
    // Temperature: 25%, Rain: 20%, Humidity: 15%, Wind: 15%, AQI: 15%, UV: 10%
    final weighted = (tempScore * 0.25) +
        (rainScore * 0.20) +
        (humidScore * 0.15) +
        (windScore * 0.15) +
        (aqiScore * 0.15) +
        (uvScore * 0.10);

    final overall = weighted.round().clamp(0, 100);

    final label = _determineLabel(overall);
    final primary = _determinePrimaryFactor(
      tempScore: tempScore,
      rainScore: rainScore,
      humidScore: humidScore,
      windScore: windScore,
      aqiScore: aqiScore,
      uvScore: uvScore,
    );
    final summary = _generateSummary(overall, primary);

    return ComfortScoreResult(
      overallScore: overall,
      temperatureScore: tempScore,
      humidityScore: humidScore,
      windScore: windScore,
      rainScore: rainScore,
      uvScore: uvScore,
      aqiScore: aqiScore,
      label: label,
      summary: summary,
      primaryFactor: primary,
    );
  }

  static int _calculateTempScore(double feelsLike) {
    if (feelsLike >= 20 && feelsLike <= 25) return 100;
    if (feelsLike >= 18 && feelsLike < 20) return 92;
    if (feelsLike > 25 && feelsLike <= 28) return 88;
    if (feelsLike >= 14 && feelsLike < 18) return 78;
    if (feelsLike > 28 && feelsLike <= 32) return 70;
    if (feelsLike >= 8 && feelsLike < 14) return 58;
    if (feelsLike > 32 && feelsLike <= 36) return 48;
    if (feelsLike >= 0 && feelsLike < 8) return 38;
    if (feelsLike > 36 && feelsLike <= 40) return 28;
    if (feelsLike < 0) return 18;
    return 15; // > 40°C
  }

  static int _calculateHumidityScore(double humidity, double temp) {
    if (humidity >= 40 && humidity <= 60) return 100;
    if (humidity >= 30 && humidity < 40) return 90;
    if (humidity > 60 && humidity <= 70) return 85;
    if (humidity > 70 && humidity <= 80) return (temp > 28) ? 60 : 75;
    if (humidity > 80) return (temp > 28) ? 40 : 60;
    return 65; // < 30% very dry
  }

  static int _calculateWindScore(double windKmh) {
    if (windKmh >= 4 && windKmh <= 15) return 100;
    if (windKmh < 4) return 90; // calm
    if (windKmh > 15 && windKmh <= 25) return 85;
    if (windKmh > 25 && windKmh <= 38) return 68;
    if (windKmh > 38 && windKmh <= 50) return 45;
    return 20; // > 50 gale
  }

  static int _calculateRainScore(double rainProb, double precipMm) {
    if (precipMm > 5.0) return 15;
    if (precipMm > 1.0) return 30;
    if (rainProb == 0) return 100;
    if (rainProb <= 15) return 92;
    if (rainProb <= 30) return 80;
    if (rainProb <= 50) return 60;
    if (rainProb <= 75) return 38;
    return 20;
  }

  static int _calculateUvScore(double uv) {
    if (uv < 3) return 100;
    if (uv < 6) return 85;
    if (uv < 8) return 65;
    if (uv < 11) return 40;
    return 20;
  }

  static int _calculateAqiScore(int aqi) {
    if (aqi <= 30) return 100;
    if (aqi <= 50) return 88;
    if (aqi <= 75) return 70;
    if (aqi <= 100) return 50;
    if (aqi <= 150) return 35;
    return 15;
  }

  static String _determineLabel(int score) {
    if (score >= 85) return 'Optimal Comfort';
    if (score >= 70) return 'Pleasant';
    if (score >= 55) return 'Moderate';
    if (score >= 40) return 'Uncomfortable';
    return 'Challenging';
  }

  static String _determinePrimaryFactor({
    required int tempScore,
    required int rainScore,
    required int humidScore,
    required int windScore,
    required int aqiScore,
    required int uvScore,
  }) {
    final factors = [
      MapEntry('Temperature', tempScore),
      MapEntry('Rain Risk', rainScore),
      MapEntry('Humidity', humidScore),
      MapEntry('Wind', windScore),
      MapEntry('Air Quality', aqiScore),
      MapEntry('UV Index', uvScore),
    ];

    // Find the factor with the lowest score (most limiting factor)
    factors.sort((a, b) => a.value.compareTo(b.value));
    return factors.first.key;
  }

  static String _generateSummary(int overall, String primaryFactor) {
    if (overall >= 85) {
      return 'Exceptional outdoor conditions with great air quality and ideal thermal comfort.';
    } else if (overall >= 70) {
      return 'Good overall conditions. Slight impact from $primaryFactor.';
    } else if (overall >= 55) {
      return 'Moderate weather comfort. Noticeable impact from $primaryFactor.';
    } else if (overall >= 40) {
      return 'Suboptimal comfort today. Main disruption: $primaryFactor.';
    } else {
      return 'Harsh conditions. Stay indoors or take precautions for $primaryFactor.';
    }
  }
}
