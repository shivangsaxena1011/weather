import 'package:flutter/material.dart';

/// AQI level constants and helpers.
class AqiLevels {
  AqiLevels._();

  static const int good = 50;
  static const int moderate = 100;
  static const int unhealthySensitive = 150;
  static const int unhealthy = 200;
  static const int veryUnhealthy = 300;

  static Color colorForAqi(int aqi) {
    if (aqi <= good) return const Color(0xFF4CAF50);
    if (aqi <= moderate) return const Color(0xFFFFC107);
    if (aqi <= unhealthySensitive) return const Color(0xFFFF9800);
    if (aqi <= unhealthy) return const Color(0xFFF44336);
    if (aqi <= veryUnhealthy) return const Color(0xFF9C27B0);
    return const Color(0xFF7B1FA2);
  }

  static String labelForAqi(int aqi) {
    if (aqi <= good) return 'Good';
    if (aqi <= moderate) return 'Moderate';
    if (aqi <= unhealthySensitive) return 'Unhealthy (Sensitive)';
    if (aqi <= unhealthy) return 'Unhealthy';
    if (aqi <= veryUnhealthy) return 'Very Unhealthy';
    return 'Hazardous';
  }
}
