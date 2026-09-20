import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/aqi_formatter.dart';
import '../../core/utils/unit_converter.dart';
import '../../core/utils/weather_helpers.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/air_quality_model.dart';
import '../../providers/unit_provider.dart';
import '../common/weather_card.dart';

class HealthWidget extends ConsumerWidget {
  final WeatherModel weather;
  final AirQualityModel airQuality;

  const HealthWidget({
    super.key,
    required this.weather,
    required this.airQuality,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unitSettings = ref.watch(unitSettingsProvider);
    final aqiColor = AqiFormatter.color(airQuality.aqi);
    final aqiLabel = AqiFormatter.label(airQuality.aqi);
    final advice = AqiFormatter.healthAdvice(airQuality.aqi);
    final healthTip = AqiFormatter.healthTip(
      aqi: airQuality.aqi,
      grassPollen: airQuality.grassPollen,
      treePollen: airQuality.treePollen,
      weedPollen: airQuality.weedPollen,
      uvIndex: airQuality.uvIndex,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dynamic Health Tip Banner
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E281F) : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF4CAF50).withOpacity(0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Allergy & Asthma Advisory',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      healthTip,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : const Color(0xFF1B5E20),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // AQI Detailed Card
        WeatherCard(
          title: 'AIR QUALITY INDEX (AQI)',
          titleTrailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: aqiColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              aqiLabel,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: aqiColor,
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
                    '${airQuality.aqi}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: aqiColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'European AQI',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // AQI Gauge Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (airQuality.aqi / 200).clamp(0.05, 1.0),
                  minHeight: 10,
                  backgroundColor: isDark
                      ? Colors.white10
                      : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(aqiColor),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                advice,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              // Pollutants Breakdown
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _pollutantPill(isDark, 'PM2.5', '${airQuality.pm25.toStringAsFixed(1)} µg/m³'),
                  _pollutantPill(isDark, 'PM10', '${airQuality.pm10.toStringAsFixed(1)} µg/m³'),
                  _pollutantPill(isDark, 'NO₂', '${airQuality.no2.toStringAsFixed(1)} µg/m³'),
                  _pollutantPill(isDark, 'O₃', '${airQuality.o3.toStringAsFixed(1)} µg/m³'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pollen Counts Card
        WeatherCard(
          title: 'POLLEN COUNTS & ALLERGENS',
          child: Column(
            children: [
              _pollenRow(
                isDark,
                name: 'Grass Pollen',
                icon: '🌾',
                count: airQuality.grassPollen,
              ),
              const Divider(height: 18),
              _pollenRow(
                isDark,
                name: 'Tree Pollen',
                icon: '🌳',
                count: airQuality.treePollen,
              ),
              const Divider(height: 18),
              _pollenRow(
                isDark,
                name: 'Weed Pollen',
                icon: '🌿',
                count: airQuality.weedPollen,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // UV Index & Skin Sensitivity
        Row(
          children: [
            Expanded(
              child: WeatherCard(
                title: 'UV INDEX',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.uvIndex.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: WeatherHelpers.uvColor(weather.uvIndex),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      WeatherHelpers.uvLabel(weather.uvIndex),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: WeatherHelpers.uvColor(weather.uvIndex),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      WeatherHelpers.burnTime(weather.uvIndex),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WeatherCard(
                title: 'HUMIDITY & SKIN',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.humidity.round()}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0288D1),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      WeatherHelpers.skinComfort(weather.humidity, weather.currentTemp),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF0288D1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dew point: ${UnitConverter.formatTemp(weather.dewPoint, unitSettings.tempUnit)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
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

  Widget _pollutantPill(bool isDark, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262F40) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _pollenRow(
    bool isDark, {
    required String name,
    required String icon,
    required double count,
  }) {
    final risk = AqiFormatter.pollenRisk(count);
    final color = AqiFormatter.pollenColor(count);

    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            risk,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
