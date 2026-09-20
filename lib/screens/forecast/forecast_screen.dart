import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/weather_helpers.dart';
import '../../core/utils/unit_converter.dart';
import '../../providers/weather_provider.dart';
import '../../providers/persona_provider.dart';
import '../../providers/unit_provider.dart';
import '../../widgets/common/weather_card.dart';

class ForecastScreen extends ConsumerWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bundleAsync = ref.watch(weatherDataProvider);
    final persona = ref.watch(personaProvider);
    final unitSettings = ref.watch(unitSettingsProvider);
    final accent = Personas.color(persona);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detailed Forecast',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: bundleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 54, color: Colors.grey),
                const SizedBox(height: 12),
                const Text(
                  'Unable to Load Forecast',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Check your internet connection or tap retry.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                  onPressed: () => ref.invalidate(weatherDataProvider),
                ),
              ],
            ),
          ),
        ),
        data: (bundle) {
          final weather = bundle.weather;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location & Current Overview
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bundle.location.cityName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Next 7 Days Outlook',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        UnitConverter.formatTemp(weather.currentTemp, unitSettings.tempUnit),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 24-Hour Timeline Carousel
                WeatherCard(
                  title: 'HOURLY TEMPERATURE TIMELINE (24h)',
                  child: SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: weather.hourly.take(24).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final h = weather.hourly[i];
                        final hourStr = i == 0
                            ? 'Now'
                            : '${h.time.hour % 12 == 0 ? 12 : h.time.hour % 12} ${h.time.hour >= 12 ? 'PM' : 'AM'}';
                        final emoji = WeatherHelpers.codeToEmoji(h.weatherCode);

                        return Container(
                          width: 68,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF262D3D) : const Color(0xFFF8F9FD),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: i == 0
                                  ? accent
                                  : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                              width: i == 0 ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                hourStr,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                ),
                              ),
                              Text(emoji, style: const TextStyle(fontSize: 22)),
                              Text(
                                UnitConverter.formatTemp(h.temperature, unitSettings.tempUnit, showUnit: false),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (h.precipitationProbability > 20)
                                Text(
                                  '${h.precipitationProbability.round()}%',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0288D1),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 24h Temperature FlChart Line Chart
                WeatherCard(
                  title: 'TEMPERATURE TREND (${unitSettings.tempUnit == TemperatureUnit.fahrenheit ? '°F' : '°C'})',
                  child: SizedBox(
                    height: 140,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              weather.hourly.take(12).length,
                              (i) => FlSpot(
                                i.toDouble(),
                                UnitConverter.convertTemp(weather.hourly[i].temperature, unitSettings.tempUnit),
                              ),
                            ),
                            isCurved: true,
                            color: accent,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: accent.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 7-Day Day-by-Day Forecast
                WeatherCard(
                  title: '7-DAY OUTLOOK',
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: weather.daily.take(7).length,
                    separatorBuilder: (_, __) => Divider(
                      height: 16,
                      color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                    ),
                    itemBuilder: (context, i) {
                      final d = weather.daily[i];
                      final dayName = i == 0
                          ? 'Today'
                          : (i == 1 ? 'Tomorrow' : DateFormat('EEEE').format(d.date));
                      final emoji = WeatherHelpers.codeToEmoji(d.weatherCode);
                      final desc = WeatherHelpers.codeToDescription(d.weatherCode);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                dayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            Text(emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                desc,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  UnitConverter.formatTemp(d.tempMax, unitSettings.tempUnit, showUnit: false),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  UnitConverter.formatTemp(d.tempMin, unitSettings.tempUnit, showUnit: false),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
