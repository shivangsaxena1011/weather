import 'package:flutter/material.dart';

/// Persona constants used across the app.
class Personas {
  Personas._();

  static const String health = 'health';
  static const String fitness = 'fitness';
  static const String beach = 'beach';
  static const String traveler = 'traveler';
  static const String family = 'family';
  static const String agriculture = 'agriculture';
  static const String commuter = 'commuter';
  static const String event = 'event';

  static const all = [
    health,
    fitness,
    beach,
    traveler,
    family,
    agriculture,
    commuter,
    event,
  ];

  static String label(String persona) {
    switch (persona) {
      case health:
        return 'Health';
      case fitness:
        return 'Fitness';
      case beach:
        return 'Beach';
      case traveler:
        return 'Traveler';
      case family:
        return 'Family';
      case agriculture:
        return 'Agriculture';
      case commuter:
        return 'Commuter';
      case event:
        return 'Events';
      default:
        return persona;
    }
  }

  static String icon(String persona) {
    switch (persona) {
      case health:
        return '🏥';
      case fitness:
        return '🏃';
      case beach:
        return '🏖️';
      case traveler:
        return '✈️';
      case family:
        return '👨‍👩‍👧';
      case agriculture:
        return '🌾';
      case commuter:
        return '🚗';
      case event:
        return '🎉';
      default:
        return '🌤️';
    }
  }

  static Color color(String persona) {
    switch (persona) {
      case health:
        return const Color(0xFF4CAF50);
      case fitness:
        return const Color(0xFF2196F3);
      case beach:
        return const Color(0xFF00BCD4);
      case traveler:
        return const Color(0xFF9C27B0);
      case family:
        return const Color(0xFFFF9800);
      case agriculture:
        return const Color(0xFF8BC34A);
      case commuter:
        return const Color(0xFF607D8B);
      case event:
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF03A9F4);
    }
  }
}
