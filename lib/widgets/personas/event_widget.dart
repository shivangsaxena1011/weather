import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/weather_helpers.dart';
import '../../data/models/weather_model.dart';
import '../common/weather_card.dart';

class EventWidget extends StatelessWidget {
  final WeatherModel weather;

  const EventWidget({
    super.key,
    required this.weather,
  });

  double _calculateComfortScore(DailyWeather day) {
    double score = 100.0;
    // Temp penalty: best 20 - 26 C
    final avgTemp = (day.tempMax + day.tempMin) / 2;
    if (avgTemp < 15 || avgTemp > 30) {
      score -= 30;
    } else if (avgTemp < 18 || avgTemp > 27) {
      score -= 15;
    }
    // Rain penalty
    if (day.precipitationProbabilityMax > 60) {
      score -= 40;
    } else if (day.precipitationProbabilityMax > 30) {
      score -= 20;
    }
    // Wind penalty
    if (day.windSpeedMax > 35) {
      score -= 20;
    }
    return score.clamp(10.0, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Personas.color(Personas.event);

    final todayComfort = weather.daily.isNotEmpty
        ? _calculateComfortScore(weather.daily.first).round()
        : 78;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Outdoor Comfort Score Banner
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF381928), const Color(0xFF1E151A)]
                  : [const Color(0xFFFCE4EC), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.35), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.2),
                  border: Border.all(color: accent, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$todayComfort',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todayComfort >= 75
                          ? 'Perfect for Outdoor Weddings & Parties! 🎉'
                          : (todayComfort >= 50
                              ? 'Fair for Gatherings (Have Canopy/Tent) ⛺'
                              : 'Outdoor Discomfort: Indoor Recommended 🏛️'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Outdoor Comfort Index evaluates temperature, rain probability, and gust speed.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 7-Day Event Suitability Strip
        WeatherCard(
          title: '7-DAY EVENT PLANNER FORECAST',
          child: SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: weather.daily.take(7).length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final d = weather.daily[i];
                final dayStr = DateFormat('EEE').format(d.date);
                final comfort = _calculateComfortScore(d).round();
                final emoji = WeatherHelpers.codeToEmoji(d.weatherCode);

                return Container(
                  width: 82,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262D3D) : const Color(0xFFF8F9FD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: comfort >= 75
                          ? accent.withOpacity(0.5)
                          : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                      width: comfort >= 75 ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dayStr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      Text(
                        '${d.tempMax.round()}° / ${d.tempMin.round()}°',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (d.precipitationProbabilityMax > 40
                                  ? const Color(0xFF0288D1)
                                  : const Color(0xFF4CAF50))
                              .withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${d.precipitationProbabilityMax.round()}% rain',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: d.precipitationProbabilityMax > 40
                                ? const Color(0xFF0288D1)
                                : const Color(0xFF388E3C),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Rain Probability & Tent Warning
        WeatherCard(
          title: 'EVENT LOGISTICS & RAIN RISK',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Precipitation Risk:'),
                  Text(
                    '${weather.precipitationProbability.round()}% Probability',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: weather.precipitationProbability > 40
                          ? const Color(0xFFE53935)
                          : const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (weather.precipitationProbability / 100).clamp(0.02, 1.0),
                  minHeight: 8,
                  backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    weather.precipitationProbability > 40
                        ? const Color(0xFFE53935)
                        : const Color(0xFF4CAF50),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                weather.precipitationProbability > 40
                    ? '⚠️ High rain probability. We recommend booking a backup marquee, waterproof flooring, and enclosed dining areas.'
                    : '✅ Excellent outdoor weather expected. Lawns and open-air spaces are fully suitable.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
