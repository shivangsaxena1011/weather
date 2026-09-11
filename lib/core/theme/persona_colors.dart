import 'package:flutter/material.dart';
import '../constants/personas.dart';

class PersonaColors {
  PersonaColors._();

  static Color getAccent(String persona) {
    return Personas.color(persona);
  }

  static LinearGradient getGradient(String persona, {bool isDark = false}) {
    final base = Personas.color(persona);
    if (isDark) {
      return LinearGradient(
        colors: [
          base.withOpacity(0.35),
          const Color(0xFF141923),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [
        base.withOpacity(0.20),
        Colors.white,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Color getCardBackground(String persona, {bool isDark = false}) {
    if (isDark) {
      return const Color(0xFF1E2430);
    }
    final base = Personas.color(persona);
    return Color.alphaBlend(base.withOpacity(0.04), const Color(0xFFF9FAFC));
  }
}
