import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/unit_converter.dart';
import '../../core/utils/weather_helpers.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/marine_model.dart';
import '../../providers/unit_provider.dart';
import '../common/weather_card.dart';

class BeachWidget extends ConsumerWidget {
  final WeatherModel weather;
  final MarineModel marine;

  const BeachWidget({
    super.key,
    required this.weather,
    required this.marine,
  });

  String _getBeachSafetyLabel() {
    if (marine.waveHeight > 2.5 || weather.windSpeed > 50) {
      return 'Dangerous Conditions 🔴';
    }
    if (marine.waveHeight > 1.5 || weather.windSpeed > 30) {
      return 'Caution Advised 🟡';
    }
    return 'Safe for Swimming 🟢';
  }

  Color _getBeachSafetyColor() {
    if (marine.waveHeight > 2.5 || weather.windSpeed > 50) {
      return const Color(0xFFD32F2F);
    }
    if (marine.waveHeight > 1.5 || weather.windSpeed > 30) {
      return const Color(0xFFF57C00);
    }
    return const Color(0xFF388E3C);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unitSettings = ref.watch(unitSettingsProvider);
    final safetyColor = _getBeachSafetyColor();
    final safetyLabel = _getBeachSafetyLabel();

    final highTideStr =
        DateFormat('hh:mm a').format(marine.nextHighTideTime);
    final lowTideStr =
        DateFormat('hh:mm a').format(marine.nextLowTideTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Beach Safety Banner
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: safetyColor.withOpacity(isDark ? 0.25 : 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: safetyColor.withOpacity(0.4), width: 1.2),
          ),
          child: Row(
            children: [
              const Text('🚩', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      safetyLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: safetyColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      marine.waveHeight <= 1.5
                          ? 'Gentle swells and light currents. Ideal for families and swimming.'
                          : 'Moderate to high surf. Rip currents possible. Stay near lifeguards.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Wave Height & Surf Conditions Card
        WeatherCard(
          title: 'SEA CONDITIONS & WAVES',
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          marine.waveHeight.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0288D1),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'm',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Wave Height',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${marine.wavePeriod.round()}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0097A7),
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          'sec',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Wave Period',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${UnitConverter.convertTemp(marine.seaTemperature, unitSettings.tempUnit).round()}°',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00897B),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          unitSettings.tempUnit == TemperatureUnit.fahrenheit ? 'F' : 'C',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Water Temp',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tide Timings Card
        WeatherCard(
          title: 'TIDE PREDICTIONS',
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2838) : const Color(0xFFE1F5FE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_upward_rounded, size: 16, color: Color(0xFF0288D1)),
                          SizedBox(width: 4),
                          Text(
                            'High Tide',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0288D1)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        highTideStr,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${marine.nextHighTideHeight.toStringAsFixed(2)} m',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF28241E) : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_downward_rounded, size: 16, color: Color(0xFFF57F17)),
                          SizedBox(width: 4),
                          Text(
                            'Low Tide',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFF57F17)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lowTideStr,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${marine.nextLowTideHeight.toStringAsFixed(2)} m',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Surfing & Sun Protection
        Row(
          children: [
            Expanded(
              child: WeatherCard(
                title: 'SWELL DIRECTION',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${marine.swellWaveDirection.round()}° ${WeatherHelpers.degreesToCardinal(marine.swellWaveDirection)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03A9F4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Swell: ${marine.swellWaveHeight.toStringAsFixed(1)}m',
                      style: TextStyle(
                        fontSize: 12,
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
                title: 'BEACH UV ADVICE',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UV ${weather.uvIndex.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: WeatherHelpers.uvColor(weather.uvIndex),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.uvIndex > 6
                          ? 'Apply SPF 50+ water-resistant'
                          : 'Standard sunscreen ok',
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
}
