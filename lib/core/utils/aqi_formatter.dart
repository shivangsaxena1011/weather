import 'package:flutter/material.dart';

/// Utility class for formatting and interpreting AQI values.
class AqiFormatter {
  AqiFormatter._();

  /// Returns the AQI level label (Good, Moderate, etc).
  static String label(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  /// Returns the color associated with the AQI level.
  static Color color(int aqi) {
    if (aqi <= 50) return const Color(0xFF4CAF50);
    if (aqi <= 100) return const Color(0xFFFFC107);
    if (aqi <= 150) return const Color(0xFFFF9800);
    if (aqi <= 200) return const Color(0xFFF44336);
    if (aqi <= 300) return const Color(0xFF9C27B0);
    return const Color(0xFF7B1FA2);
  }

  /// Returns a health advice string for the given AQI.
  static String healthAdvice(int aqi) {
    if (aqi <= 50) {
      return 'Air quality is satisfactory. Enjoy outdoor activities!';
    }
    if (aqi <= 100) {
      return 'Acceptable quality. Sensitive individuals should limit prolonged outdoor exertion.';
    }
    if (aqi <= 150) {
      return 'Members of sensitive groups may experience health effects. Wear a mask outdoors.';
    }
    if (aqi <= 200) {
      return 'Everyone may begin to experience health effects. Reduce outdoor activities.';
    }
    if (aqi <= 300) {
      return 'Health alert! Everyone may experience serious effects. Stay indoors.';
    }
    return 'Emergency conditions. Avoid all outdoor exertion.';
  }

  /// Returns the pollen risk label for a given pollen count.
  static String pollenRisk(double count) {
    if (count < 10) return 'Low';
    if (count < 30) return 'Moderate';
    if (count < 80) return 'High';
    return 'Very High';
  }

  /// Returns the color for a pollen risk level.
  static Color pollenColor(double count) {
    if (count < 10) return const Color(0xFF4CAF50);
    if (count < 30) return const Color(0xFFFFC107);
    if (count < 80) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  /// Returns a dynamic health tip based on AQI, pollen and UV.
  static String healthTip({
    required int aqi,
    required double grassPollen,
    required double treePollen,
    required double weedPollen,
    required double uvIndex,
  }) {
    final maxPollen = [grassPollen, treePollen, weedPollen]
        .reduce((a, b) => a > b ? a : b);

    if (aqi > 150) {
      return '😷 Air quality is unhealthy today. Stay indoors and use an air purifier.';
    }
    if (maxPollen > 80) {
      return '🤧 Very high pollen levels. Take antihistamines before going outside.';
    }
    if (uvIndex > 8) {
      return '🧴 Extreme UV index! Apply SPF 50+ sunscreen and wear protective clothing.';
    }
    if (aqi > 100) {
      return '⚠️ Moderate air quality. Sensitive groups should reduce outdoor time.';
    }
    if (maxPollen > 30) {
      return '🌿 Moderate pollen today. Those with allergies should keep windows closed.';
    }
    if (uvIndex > 5) {
      return '☀️ Moderate UV levels. Apply SPF 30+ sunscreen if spending time outdoors.';
    }
    return '🌱 Air quality is good! A great day for outdoor activities.';
  }
}
