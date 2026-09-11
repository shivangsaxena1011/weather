import 'package:flutter/material.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/weather_helpers.dart';
import '../../data/models/weather_model.dart';

class CurrentWeatherHero extends StatelessWidget {
  final WeatherModel weather;
  final String persona;
  final VoidCallback onForecastTap;

  const CurrentWeatherHero({
    super.key,
    required this.weather,
    required this.persona,
    required this.onForecastTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = Personas.color(persona);
    final description =
        WeatherHelpers.codeToDescription(weather.weatherCode);
    final emoji = WeatherHelpers.codeToEmoji(weather.weatherCode);

    final todayMin = weather.daily.isNotEmpty
        ? weather.daily.first.tempMin.round()
        : (weather.currentTemp - 4).round();
    final todayMax = weather.daily.isNotEmpty
        ? weather.daily.first.tempMax.round()
        : (weather.currentTemp + 5).round();

    return InkWell(
      onTap: onForecastTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1E2536),
                    accent.withOpacity(0.18),
                    const Color(0xFF141923),
                  ]
                : [
                    Colors.white,
                    accent.withOpacity(0.10),
                    const Color(0xFFF1F5F9),
                  ],
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
                      '${weather.currentTemp.round()}°',
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
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
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
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickMetric(
                  context,
                  icon: Icons.thermostat_rounded,
                  label: 'Feels like',
                  value: '${weather.feelsLike.round()}°C',
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
                  value: '${weather.windSpeed.round()} km/h',
                  accent: accent,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '7-Day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: accent.withOpacity(0.85)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
