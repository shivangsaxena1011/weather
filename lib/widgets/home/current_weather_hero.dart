import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/weather_helpers.dart';
import '../../core/utils/unit_converter.dart';
import '../../data/models/weather_model.dart';
import '../../providers/unit_provider.dart';

class CurrentWeatherHero extends ConsumerWidget {
  final WeatherModel weather;
  final String persona;
  final VoidCallback onForecastTap;

  const CurrentWeatherHero({
    super.key,
    required this.weather,
    required this.persona,
    required this.onForecastTap,
  });

  List<Color> _getDynamicWeatherGradient(int code, bool isDark, Color accent) {
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour >= 19;

    if (isNight) {
      return isDark
          ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B), const Color(0xFF090D16)]
          : [const Color(0xFF1E293B), const Color(0xFF312E81), const Color(0xFF0F172A)];
    }

    if (code >= 95) {
      // Thunderstorm
      return isDark
          ? [const Color(0xFF1C1917), const Color(0xFF3B0764), const Color(0xFF18181B)]
          : [const Color(0xFF312E81), const Color(0xFF581C87), const Color(0xFF1E1B4B)];
    }

    if (code >= 61 && code <= 82) {
      // Rain
      return isDark
          ? [const Color(0xFF0C4A6E), const Color(0xFF1E293B), const Color(0xFF082F49)]
          : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD), const Color(0xFFF0F9FF)];
    }

    if (code == 45 || code == 48) {
      // Fog
      return isDark
          ? [const Color(0xFF334155), const Color(0xFF1E293B), const Color(0xFF0F172A)]
          : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)];
    }

    if (code >= 71 && code <= 86) {
      // Snow
      return isDark
          ? [const Color(0xFF1E293B), const Color(0xFF0369A1), const Color(0xFF0C4A6E)]
          : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE), Colors.white];
    }

    if (code == 3) {
      // Overcast
      return isDark
          ? [const Color(0xFF1E293B), const Color(0xFF334155), const Color(0xFF0F172A)]
          : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0), const Color(0xFFF1F5F9)];
    }

    if (code == 1 || code == 2) {
      // Partly Cloudy
      return isDark
          ? [const Color(0xFF1E2536), accent.withOpacity(0.22), const Color(0xFF141923)]
          : [Colors.white, accent.withOpacity(0.12), const Color(0xFFF0F9FF)];
    }

    // Clear Sky / Sunny
    return isDark
        ? [const Color(0xFF1E2536), accent.withOpacity(0.25), const Color(0xFF141923)]
        : [Colors.white, const Color(0xFFFEF3C7), const Color(0xFFFFFBEB)];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = Personas.color(persona);
    final unitSettings = ref.watch(unitSettingsProvider);

    final description = WeatherHelpers.codeToDescription(weather.weatherCode);
    final emoji = WeatherHelpers.codeToEmoji(weather.weatherCode);

    final tempStr = UnitConverter.formatTemp(
      weather.currentTemp,
      unitSettings.tempUnit,
      showUnit: false,
    );
    final feelsLikeStr = UnitConverter.formatTemp(
      weather.feelsLike,
      unitSettings.tempUnit,
    );
    final windStr = UnitConverter.formatWind(
      weather.windSpeed,
      unitSettings.windUnit,
    );

    final todayMin = weather.daily.isNotEmpty
        ? UnitConverter.formatTemp(weather.daily.first.tempMin, unitSettings.tempUnit, showUnit: false)
        : UnitConverter.formatTemp(weather.currentTemp - 4, unitSettings.tempUnit, showUnit: false);
    final todayMax = weather.daily.isNotEmpty
        ? UnitConverter.formatTemp(weather.daily.first.tempMax, unitSettings.tempUnit, showUnit: false)
        : UnitConverter.formatTemp(weather.currentTemp + 5, unitSettings.tempUnit, showUnit: false);

    final bgColors = _getDynamicWeatherGradient(weather.weatherCode, isDark, accent);

    return InkWell(
      onTap: onForecastTap,
      borderRadius: BorderRadius.circular(28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: bgColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: accent.withOpacity(isDark ? 0.35 : 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(isDark ? 0.2 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$tempStr°',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        height: 1.0,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  H:$todayMax° L:$todayMin°',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 60),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickMetric(
                  context,
                  icon: Icons.thermostat_rounded,
                  label: 'Feels like',
                  value: feelsLikeStr,
                  accent: accent,
                ),
                _buildQuickMetric(
                  context,
                  icon: Icons.water_drop_rounded,
                  label: 'Humidity',
                  value: '${weather.humidity.round()}%',
                  accent: accent,
                ),
                _buildQuickMetric(
                  context,
                  icon: Icons.air_rounded,
                  label: 'Wind',
                  value: windStr,
                  accent: accent,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '7-Day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: accent,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: accent),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
