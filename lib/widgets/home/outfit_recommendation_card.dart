import 'package:flutter/material.dart';
import '../../engines/outfit_recommendation_engine.dart';
import '../common/weather_card.dart';

class OutfitRecommendationCard extends StatelessWidget {
  final List<OutfitItem> items;
  final Color accent;

  const OutfitRecommendationCard({
    super.key,
    required this.items,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WeatherCard(
      title: '👕 WHAT SHOULD I WEAR TODAY?',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141923) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
