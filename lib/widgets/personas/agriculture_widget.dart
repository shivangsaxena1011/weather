import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/unit_converter.dart';
import '../../data/models/weather_model.dart';
import '../../providers/unit_provider.dart';
import '../common/weather_card.dart';

class AgricultureWidget extends ConsumerWidget {
  final WeatherModel weather;

  const AgricultureWidget({
    super.key,
    required this.weather,
  });

  bool _hasFrostAlert() {
    return weather.daily.any((d) => d.tempMin <= 2.0);
  }

  String _getPlantingAdvice() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) {
      return 'Spring Sowing: Great season for tomatoes, peppers, melons, and leafy greens. Keep soil aerated.';
    } else if (month >= 6 && month <= 8) {
      return 'Summer Care: Irrigate during early morning or late evening. Mulch around roots to prevent evaporation.';
    } else if (month >= 9 && month <= 11) {
      return 'Autumn Planting: Ideal for garlic, onions, spinach, carrots, and winter cover crops.';
    } else {
      return 'Winter Maintenance: Protect delicate crops with frost fleece. Prune dormant fruit trees.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Personas.color(Personas.agriculture);
    final unitSettings = ref.watch(unitSettingsProvider);
    final hasFrost = _hasFrostAlert();

    final soilMoisture = weather.daily.isNotEmpty
        ? weather.daily.first.soilMoisture
        : 35.0;

    final et0 = weather.daily.isNotEmpty
        ? weather.daily.first.et0FaoEvapotranspiration
        : 4.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frost Alert Banner (Critical for farmers & gardeners)
        if (hasFrost)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2838) : const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00ACC1), width: 1.2),
            ),
            child: Row(
              children: [
                const Text('❄️', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Frost Advisory for Crops & Plants',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00838F),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Temperatures falling to near or below freezing (≤ ${UnitConverter.formatTemp(2, unitSettings.tempUnit)}) in upcoming days. Cover sensitive plants and irrigate beforehand.',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Soil Moisture & Evapotranspiration
        Row(
          children: [
            Expanded(
              child: WeatherCard(
                title: 'SOIL MOISTURE (0-10cm)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${soilMoisture.round()}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Text('%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (soilMoisture / 100).clamp(0.05, 1.0),
                        minHeight: 8,
                        backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      soilMoisture < 25
                          ? 'Low: Irrigation Needed 🚿'
                          : (soilMoisture > 70
                              ? 'Saturated: Risk of Root Rot'
                              : 'Optimal Moisture Level ✅'),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: soilMoisture < 25 ? const Color(0xFFD32F2F) : accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WeatherCard(
                title: 'EVAPOTRANSPIRATION (ET₀)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          et0.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0097A7),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Text('mm/d', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      et0 > 5.0
                          ? 'High water loss rate today. Increase watering schedule.'
                          : 'Moderate water consumption rate.',
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
        const SizedBox(height: 16),

        // 7-Day Rainfall Forecast Bar Chart
        WeatherCard(
          title: '7-DAY PRECIPITATION OUTLOOK (mm)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 140,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 20,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                            final i = val.toInt();
                            if (i >= 0 && i < weather.daily.length) {
                              final d = weather.daily[i].date;
                              const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  days[d.weekday - 1],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      weather.daily.take(7).length,
                      (i) {
                        final rain = weather.daily[i].precipitationSum;
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: rain.clamp(0.5, 20),
                              color: rain > 5 ? const Color(0xFF1976D2) : const Color(0xFF90CAF9),
                              width: 14,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Seasonal Planting Guidance Card
        WeatherCard(
          title: 'SEASONAL PLANTING GUIDANCE',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🌱', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getPlantingAdvice(),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
