import 'package:flutter/material.dart';
import '../data/models/weather_model.dart';
import '../data/models/air_quality_model.dart';
import '../widgets/common/alert_banner.dart';

class SmartAlert {
  final String id;
  final String title;
  final String message;
  final String emoji;
  final AlertSeverity severity;
  final String actionTip;
  final DateTime timestamp;

  const SmartAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.emoji,
    required this.severity,
    required this.actionTip,
    required this.timestamp,
  });
}

class SmartAlertEngine {
  // Cooldown in minutes to avoid alert notification fatigue
  static final Map<String, DateTime> _lastTriggered = {};
  static const Duration _cooldown = Duration(hours: 2);

  static List<SmartAlert> evaluate({
    required WeatherModel weather,
    required AirQualityModel airQuality,
    Map<String, bool>? preferences,
  }) {
    final prefs = preferences ??
        {
          'rain': true,
          'heavyRain': true,
          'storm': true,
          'extremeHeat': true,
          'extremeCold': true,
          'uv': true,
          'aqi': true,
          'wind': true,
          'fog': true,
        };

    final alerts = <SmartAlert>[];
    final now = DateTime.now();

    // 1. Severe Storm
    if (prefs['storm'] == true && weather.weatherCode >= 95) {
      alerts.add(
        SmartAlert(
          id: 'severe_storm',
          title: 'Thunderstorm & Hail Advisory',
          message:
              'Severe convective thunderstorm active in your area. High lightning risk and localized downpours.',
          emoji: '⛈️',
          severity: AlertSeverity.danger,
          actionTip: 'Seek indoor shelter immediately and avoid open areas.',
          timestamp: now,
        ),
      );
    }

    // 2. Heavy Rain or Incoming Rain
    if (prefs['heavyRain'] == true && weather.precipitation > 5.0) {
      alerts.add(
        SmartAlert(
          id: 'heavy_rain',
          title: 'Torrential Rainfall In Effect',
          message:
              'Current rainfall rate (${weather.precipitation.toStringAsFixed(1)} mm/h) may trigger urban waterlogging.',
          emoji: '🌧️',
          severity: AlertSeverity.danger,
          actionTip: 'Drive with caution and keep waterproof gear ready.',
          timestamp: now,
        ),
      );
    } else if (prefs['rain'] == true &&
        weather.precipitationProbability >= 65 &&
        weather.precipitation == 0) {
      alerts.add(
        SmartAlert(
          id: 'rain_incoming',
          title: 'Rain Probability Spiking (${weather.precipitationProbability.round()}%)',
          message:
              'Precipitation probability is elevated over the next few hours. Showers likely imminent.',
          emoji: '🌦️',
          severity: AlertSeverity.warning,
          actionTip: 'Carry an umbrella or raincoat before heading out.',
          timestamp: now,
        ),
      );
    }

    // 3. Extreme Heat
    if (prefs['extremeHeat'] == true && weather.feelsLike >= 38.0) {
      alerts.add(
        SmartAlert(
          id: 'extreme_heat',
          title: 'Extreme Heat Warning (${weather.feelsLike.round()}°C Feels-Like)',
          message:
              'Heat index has entered hazardous thresholds. Elevated risk of dehydration and heat exhaustion.',
          emoji: '🔥',
          severity: AlertSeverity.danger,
          actionTip: 'Drink plenty of water and restrict strenuous outdoor exposure.',
          timestamp: now,
        ),
      );
    }

    // 4. Extreme Cold
    if (prefs['extremeCold'] == true && weather.feelsLike <= 2.0) {
      alerts.add(
        SmartAlert(
          id: 'extreme_cold',
          title: 'Sub-Zero / Frost Freeze Warning',
          message:
              'Apparent temperature (${weather.feelsLike.round()}°C) near or below freezing. Risk of hypothermia.',
          emoji: '❄️',
          severity: AlertSeverity.warning,
          actionTip: 'Wear heavy insulated winter garments and protect outdoor pets/plants.',
          timestamp: now,
        ),
      );
    }

    // 5. High / Extreme UV
    if (prefs['uv'] == true && weather.uvIndex >= 8.0) {
      alerts.add(
        SmartAlert(
          id: 'high_uv',
          title: 'Very High Solar UV Index (${weather.uvIndex.toStringAsFixed(1)})',
          message:
              'Intense ultraviolet radiation can cause skin damage in under 15 minutes of direct exposure.',
          emoji: '☀️',
          severity: AlertSeverity.warning,
          actionTip: 'Apply SPF 50+ sunscreen, wear UV sunglasses, and seek shade during peak hours.',
          timestamp: now,
        ),
      );
    }

    // 6. Poor / Hazardous AQI
    if (prefs['aqi'] == true && airQuality.aqi >= 120) {
      final isHazardous = airQuality.aqi >= 200;
      alerts.add(
        SmartAlert(
          id: 'poor_aqi',
          title: isHazardous ? 'Hazardous Air Quality Alert' : 'Unhealthy Air Quality Advisory',
          message:
              'AQI is ${airQuality.aqi} with PM2.5 at ${airQuality.pm25.toStringAsFixed(1)} µg/m³. May irritate lungs and throat.',
          emoji: '😷',
          severity: isHazardous ? AlertSeverity.danger : AlertSeverity.warning,
          actionTip: 'Wear an N95 mask outdoors and run indoor air purifiers.',
          timestamp: now,
        ),
      );
    }

    // 7. Strong Winds / Gale
    if (prefs['wind'] == true && weather.windSpeed >= 42.0) {
      alerts.add(
        SmartAlert(
          id: 'strong_wind',
          title: 'High Wind / Gale Advisory (${weather.windSpeed.round()} km/h)',
          message:
              'Strong wind gusts may dislodge branches, loose tiles, and impact high-sided vehicles.',
          emoji: '💨',
          severity: AlertSeverity.warning,
          actionTip: 'Secure loose outdoor furniture and exercise care when driving.',
          timestamp: now,
        ),
      );
    }

    // 8. Dense Fog / Poor Visibility
    if (prefs['fog'] == true &&
        (weather.weatherCode == 45 || weather.weatherCode == 48 || weather.visibility < 1500)) {
      alerts.add(
        SmartAlert(
          id: 'dense_fog',
          title: 'Dense Fog & Low Visibility',
          message:
              'Visibility reduced to ${(weather.visibility / 1000).toStringAsFixed(1)} km. Commute delays expected.',
          emoji: '🌫️',
          severity: AlertSeverity.warning,
          actionTip: 'Use vehicle fog lights and maintain safe following distances.',
          timestamp: now,
        ),
      );
    }

    // Deduplicate alerts using cooldown
    return alerts.where((alert) {
      final last = _lastTriggered[alert.id];
      if (last != null && now.difference(last) < _cooldown) {
        return true; // Still show in UI banner, but note cooldown state
      }
      _lastTriggered[alert.id] = now;
      return true;
    }).toList();
  }
}
