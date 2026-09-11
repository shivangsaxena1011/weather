import 'package:mausam/data/models/weather_model.dart';

/// Utility class that generates context-aware packing suggestions.
class PackingSuggestions {
  PackingSuggestions._();

  /// Returns a list of packing suggestion chips based on current conditions.
  static List<String> getSuggestions(WeatherModel weather) {
    final suggestions = <String>[];
    final temp = weather.currentTemp;
    final precip = weather.precipitationProbability;
    final wind = weather.windSpeed;
    final uv = weather.uvIndex;
    final code = weather.weatherCode;

    // Temperature-based
    if (temp < 5) {
      suggestions.addAll(['🧥 Heavy Coat', '🧤 Gloves', '🧣 Scarf', '🎿 Thermals']);
    } else if (temp < 12) {
      suggestions.addAll(['🧥 Jacket', '🧣 Light Scarf', '👢 Boots']);
    } else if (temp < 20) {
      suggestions.addAll(['👕 Light Layers', '🧥 Light Jacket']);
    } else if (temp > 30) {
      suggestions.addAll(['👕 Light Clothing', '💧 Water Bottle', '🩳 Shorts']);
    }

    // Rain/precipitation
    if (precip > 50) {
      suggestions.addAll(['☂️ Umbrella', '🥾 Waterproof Shoes', '🧢 Rain Hat']);
    } else if (precip > 30) {
      suggestions.add('☂️ Foldable Umbrella');
    }

    // UV protection
    if (uv > 5) {
      suggestions.addAll(['🧴 Sunscreen SPF30+', '😎 Sunglasses', '🧢 Hat']);
    } else if (uv > 3) {
      suggestions.addAll(['🧴 Sunscreen', '😎 Sunglasses']);
    }

    // Wind
    if (wind > 40) {
      suggestions.add('💨 Windbreaker');
    }

    // Snow
    if (_isSnow(code)) {
      suggestions.addAll(['⛄ Snow Boots', '🧤 Insulated Gloves']);
    }

    // Storm
    if (_isStorm(code)) {
      suggestions.add('⛈️ Stay Indoors if Possible');
    }

    // Always
    suggestions.add('📱 Charged Phone');

    return suggestions.toSet().toList();
  }

  static bool _isSnow(int code) =>
      (code >= 71 && code <= 75) || code == 85 || code == 86;
  static bool _isStorm(int code) => code >= 95 && code <= 99;
}
