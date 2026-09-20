import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/unit_converter.dart';
import '../../core/utils/weather_helpers.dart';
import '../../data/models/weather_model.dart';
import '../../providers/unit_provider.dart';
import '../common/weather_card.dart';

class FamilyWidget extends ConsumerWidget {
  final WeatherModel weather;

  const FamilyWidget({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unitSettings = ref.watch(unitSettingsProvider);

    final isSevere = WeatherHelpers.isStorm(weather.weatherCode) ||
        weather.precipitationProbability > 75 ||
        weather.windSpeed > 45;

    final needUmbrella = weather.precipitationProbability > 40;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Severe Weather & School Warning
        if (isSevere)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF381E1E) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE53935), width: 1.2),
            ),
            child: Row(
              children: [
                const Text('🚨', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Severe Weather Alert for Kids',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC62828),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Heavy rain or high winds expected today. Monitor school transport notices and plan indoor activities.',
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

        // School Commute Conditions Card
        WeatherCard(
          title: 'DAILY SCHOOL COMMUTE OUTLOOK',
          titleTrailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: needUmbrella
                  ? const Color(0xFF0288D1).withOpacity(0.18)
                  : const Color(0xFF4CAF50).withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              needUmbrella ? 'Pack Umbrella ☂️' : 'Clear Walk 🌤️',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: needUmbrella
                    ? const Color(0xFF0288D1)
                    : const Color(0xFF388E3C),
              ),
            ),
          ),
          child: Column(
            children: [
              _commuteSlot(
                isDark,
                slotName: 'Morning Drop-off',
                time: '07:00 AM – 08:30 AM',
                temp: UnitConverter.formatTemp(weather.currentTemp, unitSettings.tempUnit),
                condition: 'Brisk & Fresh',
                icon: Icons.wb_twilight_rounded,
                safety: 'Good Commute 🟢',
                safetyColor: const Color(0xFF4CAF50),
              ),
              const Divider(height: 18),
              _commuteSlot(
                isDark,
                slotName: 'Afternoon Pick-up',
                time: '02:30 PM – 04:00 PM',
                temp: UnitConverter.formatTemp(weather.currentTemp + 3, unitSettings.tempUnit),
                condition: needUmbrella ? 'Rain Showers Likely' : 'Warm & Clear',
                icon: needUmbrella
                    ? Icons.water_drop_rounded
                    : Icons.wb_sunny_rounded,
                safety: needUmbrella ? 'Bring Raincoat 🟡' : 'Smooth Pick-up 🟢',
                safetyColor: needUmbrella
                    ? const Color(0xFFF57C00)
                    : const Color(0xFF4CAF50),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Playground & Outdoor Safety Score
        Row(
          children: [
            Expanded(
              child: WeatherCard(
                title: 'PLAYGROUND SAFETY',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.precipitationProbability < 30 && weather.uvIndex < 8
                          ? 'Great 🛝'
                          : (weather.precipitationProbability < 60
                              ? 'Fair ⛅'
                              : 'Stay Inside 🏠'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.precipitationProbability < 40
                          ? 'Park equipment is dry and safe for children.'
                          : 'Slippery equipment and rain puddles likely.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WeatherCard(
                title: 'UV FOR CHILDREN',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UV ${weather.uvIndex.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: WeatherHelpers.uvColor(weather.uvIndex),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.uvIndex > 4
                          ? 'Apply kid-friendly SPF 50+ & wide-brim hat.'
                          : 'Gentle sun. No heavy protection required.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _commuteSlot(
    bool isDark, {
    required String slotName,
    required String time,
    required String temp,
    required String condition,
    required IconData icon,
    required String safety,
    required Color safetyColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: safetyColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: safetyColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    slotName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    temp,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$condition • $safety',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: safetyColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
