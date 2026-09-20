import 'package:flutter/material.dart';
import 'package:mausam/data/models/weather_model.dart';

/// Static helpers for mapping weather codes to human-readable labels and icons.
class WeatherHelpers {
  WeatherHelpers._();

  /// Returns a weather description from an Open-Meteo weather code.
  static String codeToDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 85:
      case 86:
        return 'Snow Showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with Hail';
      default:
        return 'Unknown';
    }
  }

  /// Returns an emoji corresponding to the weather code.
  static String codeToEmoji(int code, {bool isNight = false}) {
    if (isNight) {
      switch (code) {
        case 0:
          return '🌙';
        case 1:
        case 2:
          return '☁️';
      }
    }
    switch (code) {
      case 0:
        return '☀️';
      case 1:
        return '🌤️';
      case 2:
        return '⛅';
      case 3:
        return '☁️';
      case 45:
      case 48:
        return '🌫️';
      case 51:
      case 53:
      case 55:
        return '🌦️';
      case 61:
      case 63:
      case 65:
        return '🌧️';
      case 71:
      case 73:
      case 75:
        return '❄️';
      case 80:
      case 81:
      case 82:
        return '🌦️';
      case 85:
      case 86:
        return '🌨️';
      case 95:
        return '⛈️';
      case 96:
      case 99:
        return '🌩️';
      default:
        return '🌡️';
    }
  }

  /// Returns the Beaufort scale label for a given wind speed in km/h.
  static String beaufortLabel(double windSpeedKmh) {
    if (windSpeedKmh < 1) return 'Calm';
    if (windSpeedKmh < 6) return 'Light Air';
    if (windSpeedKmh < 12) return 'Light Breeze';
    if (windSpeedKmh < 20) return 'Gentle Breeze';
    if (windSpeedKmh < 29) return 'Moderate Breeze';
    if (windSpeedKmh < 39) return 'Fresh Breeze';
    if (windSpeedKmh < 50) return 'Strong Breeze';
    if (windSpeedKmh < 62) return 'Near Gale';
    if (windSpeedKmh < 75) return 'Gale';
    if (windSpeedKmh < 89) return 'Strong Gale';
    if (windSpeedKmh < 103) return 'Storm';
    return 'Violent Storm';
  }

  /// Returns a cardinal direction string from degrees.
  static String degreesToCardinal(double degrees) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((degrees + 22.5) / 45).floor() % 8;
    return dirs[idx];
  }

  /// Returns the UV index description.
  static String uvLabel(double uv) {
    if (uv < 3) return 'Low';
    if (uv < 6) return 'Moderate';
    if (uv < 8) return 'High';
    if (uv < 11) return 'Very High';
    return 'Extreme';
  }

  /// Returns a color for a UV index value.
  static Color uvColor(double uv) {
    if (uv < 3) return const Color(0xFF4CAF50);
    if (uv < 6) return const Color(0xFFFFC107);
    if (uv < 8) return const Color(0xFFFF9800);
    if (uv < 11) return const Color(0xFFF44336);
    return const Color(0xFF9C27B0);
  }

  /// Estimated minutes to burn at the given UV index for average skin.
  static String burnTime(double uv) {
    if (uv <= 0) return 'No burn risk';
    final minutes = (200 / (uv * 3)).round();
    if (minutes > 60) return '${(minutes / 60).round()}h+ without protection';
    return '~${minutes}min without protection';
  }

  /// Whether the weather code represents a fog condition.
  static bool isFog(int code) => code == 45 || code == 48;

  /// Whether the weather code represents a storm condition.
  static bool isStorm(int code) => code >= 95 && code <= 99;

  /// Whether the weather code represents snow.
  static bool isSnow(int code) =>
      (code >= 71 && code <= 75) || code == 85 || code == 86;

  /// Comfort skin label from humidity and temperature.
  static String skinComfort(double humidity, double temp) {
    if (humidity > 80 && temp > 28) return 'Very Humid & Sticky';
    if (humidity > 70) return 'Humid';
    if (humidity < 30) return 'Dry';
    return 'Comfortable';
  }

  /// Returns the dew point color.
  static Color dewPointColor(double dew) {
    if (dew < 10) return const Color(0xFF2196F3);
    if (dew < 16) return const Color(0xFF4CAF50);
    if (dew < 21) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  /// Computes a run score out of 100 for a given hour index.
  static int runScore(WeatherModel weather, {int offsetHours = 0}) {
    final hourly = weather.hourly;
    if (hourly.isEmpty) return 50;
    final idx = offsetHours.clamp(0, hourly.length - 1);
    final h = hourly[idx];
    int score = 100;
    // Temperature penalty
    final temp = h.temperature;
    if (temp < 5 || temp > 35) {
      score -= 40;
    } else if (temp < 10 || temp > 30) {
      score -= 20;
    }
    // Wind penalty
    if (h.windSpeed > 40) {
      score -= 30;
    } else if (h.windSpeed > 25) {
      score -= 15;
    }
    // Rain penalty
    if (h.precipitationProbability > 70) {
      score -= 30;
    } else if (h.precipitationProbability > 40) {
      score -= 15;
    }
    return score.clamp(0, 100);
  }

  /// Returns feels-like alert color and label.
  static ({Color color, String label}) feelsLikeAlert(double feelsLike) {
    if (feelsLike < 10) {
      return (color: const Color(0xFF2196F3), label: 'Cold ❄️');
    }
    if (feelsLike < 18) {
      return (color: const Color(0xFF03A9F4), label: 'Cool');
    }
    if (feelsLike < 28) {
      return (color: const Color(0xFF4CAF50), label: 'Comfortable ✅');
    }
    if (feelsLike < 35) {
      return (color: const Color(0xFFFF9800), label: 'Warm ⚠️');
    }
    return (color: const Color(0xFFF44336), label: 'Hot 🔥');
  }
}
