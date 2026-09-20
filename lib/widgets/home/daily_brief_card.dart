import 'package:flutter/material.dart';
import '../../engines/daily_brief_engine.dart';
import '../common/weather_card.dart';

class DailyBriefCard extends StatelessWidget {
  final DailyBrief brief;
  final Color accent;

  const DailyBriefCard({
    super.key,
    required this.brief,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WeatherCard(
      title: '☀️ TODAY\'S PERSONALIZED BRIEF',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            brief.greeting,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            brief.headline,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
          const SizedBox(height: 12),
          ...brief.bulletPoints.map((bullet) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      bullet,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.38,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
