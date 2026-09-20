import '../data/models/weather_model.dart';

class OutfitItem {
  final String emoji;
  final String label;
  final String category; // 'tops', 'bottoms', 'layer', 'accessory', 'protection'

  const OutfitItem({
    required this.emoji,
    required this.label,
    required this.category,
  });
}

class OutfitRecommendationEngine {
  const OutfitRecommendationEngine();

  static List<OutfitItem> recommend(WeatherModel weather) {
    final items = <OutfitItem>[];
    final temp = weather.feelsLike;
    final rainProb = weather.precipitationProbability;
    final wind = weather.windSpeed;
    final uv = weather.uvIndex;
    final code = weather.weatherCode;

    // 1. Top & Primary Layer
    if (temp >= 28) {
      items.add(const OutfitItem(emoji: '👕', label: 'Light Breathable Cotton T-Shirt', category: 'tops'));
    } else if (temp >= 20) {
      items.add(const OutfitItem(emoji: '👕', label: 'Classic Cotton Shirt / Tee', category: 'tops'));
    } else if (temp >= 14) {
      items.add(const OutfitItem(emoji: '👔', label: 'Long-Sleeve Shirt or Knitwear', category: 'tops'));
    } else if (temp >= 6) {
      items.add(const OutfitItem(emoji: '🧥', label: 'Warm Sweater or Fleece', category: 'tops'));
    } else {
      items.add(const OutfitItem(emoji: '🧥', label: 'Heavy Thermal Insulated Parka', category: 'tops'));
    }

    // 2. Bottoms
    if (temp >= 27 && rainProb < 50) {
      items.add(const OutfitItem(emoji: '🩳', label: 'Breathable Shorts / Chinos', category: 'bottoms'));
    } else if (temp >= 14) {
      items.add(const OutfitItem(emoji: '👖', label: 'Light Trousers or Denim', category: 'bottoms'));
    } else {
      items.add(const OutfitItem(emoji: '👖', label: 'Heavy Corduroy / Thermal Pants', category: 'bottoms'));
    }

    // 3. Outer Layer / Windbreaker
    if (wind >= 28 || (temp < 18 && temp >= 10)) {
      items.add(const OutfitItem(emoji: '🧥', label: 'Windbreaker / Utility Jacket', category: 'layer'));
    } else if (temp < 10) {
      items.add(const OutfitItem(emoji: '🧣', label: 'Cozy Wool Scarf & Overcoat', category: 'layer'));
    }

    // 4. Rain & Moisture Gear
    if (rainProb >= 40 || weather.precipitation > 0) {
      items.add(const OutfitItem(emoji: '☂️', label: 'Compact Umbrella', category: 'protection'));
      items.add(const OutfitItem(emoji: '🥾', label: 'Water-Resistant Footwear', category: 'protection'));
    } else {
      items.add(const OutfitItem(emoji: '👟', label: 'Comfortable Sneakers', category: 'protection'));
    }

    // 5. Sun & UV Protection
    if (uv >= 6.0) {
      items.add(const OutfitItem(emoji: '🧴', label: 'SPF 50+ Sunscreen', category: 'protection'));
      items.add(const OutfitItem(emoji: '🕶️', label: 'UV-Blocking Sunglasses', category: 'accessory'));
      items.add(const OutfitItem(emoji: '🧢', label: 'Sun Shield Cap / Wide-Brim Hat', category: 'accessory'));
    } else if (uv >= 3.0) {
      items.add(const OutfitItem(emoji: '🧴', label: 'SPF 30 Sunscreen', category: 'protection'));
      items.add(const OutfitItem(emoji: '🕶️', label: 'Polarized Sunglasses', category: 'accessory'));
    }

    // 6. Freezing / Winter accessories
    if (temp <= 5 || code == 71 || code == 73 || code == 75) {
      items.add(const OutfitItem(emoji: '🧤', label: 'Insulated Winter Gloves', category: 'accessory'));
      items.add(const OutfitItem(emoji: '🎿', label: 'Thermal Base Layer', category: 'layer'));
    }

    return items;
  }
}
