import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/unit_converter.dart';
import '../../core/utils/weather_helpers.dart';
import '../../data/models/weather_model.dart';
import '../../providers/unit_provider.dart';
import '../common/weather_card.dart';

class CommuterWidget extends ConsumerWidget {
  final WeatherModel weather;

  const CommuterWidget({
    super.key,
    required this.weather,
  });

  String _getVisibilityLabel(double visibilityMeters) {
    final km = visibilityMeters / 1000;
    if (km < 1.0) return 'Dense Fog 🔴';
    if (km < 3.0) return 'Moderate Fog / Mist 🟡';
    if (km < 7.0) return 'Hazy / Fair Visibility 🟡';
    return 'Clear Highway Visibility 🟢';
  }

  Color _getVisibilityColor(double visibilityMeters) {
    final km = visibilityMeters / 1000;
    if (km < 1.0) return const Color(0xFFD32F2F);
    if (km < 5.0) return const Color(0xFFF57C00);
    return const Color(0xFF388E3C);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Personas.color(Personas.commuter);
    final unitSettings = ref.watch(unitSettingsProvider);
    final isFog = WeatherHelpers.isFog(weather.weatherCode);
    final isStorm = WeatherHelpers.isStorm(weather.weatherCode);
    final hasCommuteAlert = isFog || isStorm || weather.precipitationProbability > 65;

    final visibilityKm = (weather.visibility / 1000).toStringAsFixed(1);
    final visibilityLabel = _getVisibilityLabel(weather.visibility);
    final visibilityColor = _getVisibilityColor(weather.visibility);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Real-time Commute Alert
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasCommuteAlert
                ? (isDark ? const Color(0xFF382319) : const Color(0xFFFFF3E0))
                : (isDark ? const Color(0xFF1E2838) : const Color(0xFFECEFF1)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasCommuteAlert ? const Color(0xFFFF9800) : accent.withOpacity(0.3),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Text(
                hasCommuteAlert ? '⚠️' : '🚗',
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasCommuteAlert
                          ? (isFog
                              ? 'Dense Fog Alert — Drive with Low Beams'
                              : (isStorm
                                  ? 'Thunderstorm Alert — Expect Traffic Delays'
                                  : 'Wet Road Surfaces — Add 15m Buffer'))
                          : 'Smooth Traffic & Clear Roads Expected',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: hasCommuteAlert
                            ? const Color(0xFFE65100)
                            : (isDark ? Colors.white : const Color(0xFF263238)),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasCommuteAlert
                          ? 'Slick pavements and reduced stopping distances reported along major commuter corridors.'
                          : 'Weather is favorable for daily rush hour transit, metro, and driving.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Visibility & Highway Conditions Card
        WeatherCard(
          title: 'HIGHWAY VISIBILITY & ROAD CONDITIONS',
          titleTrailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: visibilityColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              visibilityLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: visibilityColor,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    visibilityKm,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: visibilityColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('km', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Road Surface',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        weather.precipitationProbability > 30 ? 'Wet / Slick 🌧️' : 'Dry & Clear 🛣️',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3-Hour Commute Forecast Timeline
        WeatherCard(
          title: '3-HOUR COMMUTE WEATHER TIMELINE',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              weather.hourly.take(4).length,
              (i) {
                final h = weather.hourly[i];
                final hourStr = '${h.time.hour % 12 == 0 ? 12 : h.time.hour % 12} ${h.time.hour >= 12 ? 'PM' : 'AM'}';
                final emoji = WeatherHelpers.codeToEmoji(h.weatherCode);

                return Column(
                  children: [
                    Text(
                      i == 0 ? 'Now' : hourStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Text(
                      UnitConverter.formatTemp(h.temperature, unitSettings.tempUnit),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${h.precipitationProbability.round()}% rain',
                      style: TextStyle(
                        fontSize: 11,
                        color: h.precipitationProbability > 40 ? const Color(0xFF0288D1) : Colors.grey,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
