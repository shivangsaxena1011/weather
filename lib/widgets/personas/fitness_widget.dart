import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/weather_helpers.dart';
import '../../data/models/weather_model.dart';
import '../common/weather_card.dart';

class FitnessWidget extends StatelessWidget {
  final WeatherModel weather;

  const FitnessWidget({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Personas.color(Personas.fitness);
    final heatAlert = WeatherHelpers.feelsLikeAlert(weather.feelsLike);
    final beaufort = WeatherHelpers.beaufortLabel(weather.windSpeed);
    final cardinal = WeatherHelpers.degreesToCardinal(weather.windDirection);

    final sunriseStr = weather.daily.isNotEmpty
        ? DateFormat('hh:mm a').format(weather.daily.first.sunrise)
        : '06:15 AM';
    final sunsetStr = weather.daily.isNotEmpty
        ? DateFormat('hh:mm a').format(weather.daily.first.sunset)
        : '06:45 PM';

    final runScore = WeatherHelpers.runScore(weather);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's Workout Suitability Score
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF382319), const Color(0xFF1F1A18)]
                  : [const Color(0xFFFFEDE7), Colors.white],
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
                  '$runScore',
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
                      runScore >= 75
                          ? 'Great for Outdoor Run! 🏃‍♂️'
                          : (runScore >= 50
                              ? 'Moderate Conditions 👟'
                              : 'Suboptimal: Gym Recommended 🏋️'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Score calculated from temperature, humidity, wind, and rain risk.',
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

        // Sunrise & Sunset Strip
        WeatherCard(
          title: 'DAYLIGHT & GOLDEN HOUR',
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('🌅', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sunrise',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          sunriseStr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.grey.withOpacity(0.3),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    const Text('🌇', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sunset',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          sunsetStr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Best Running Hours Card
        WeatherCard(
          title: 'BEST RUNNING HOURS TODAY',
          titleTrailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Optimal Windows',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF388E3C),
              ),
            ),
          ),
          child: Column(
            children: [
              _runWindowItem(
                isDark,
                timeWindow: '06:00 AM – 08:30 AM',
                temp: '21°C',
                condition: 'Cool & Low UV',
                icon: Icons.wb_twilight_rounded,
                isRecommended: true,
              ),
              const Divider(height: 16),
              _runWindowItem(
                isDark,
                timeWindow: '05:30 PM – 07:30 PM',
                temp: '24°C',
                condition: 'Sunset Breeze',
                icon: Icons.nightlight_round,
                isRecommended: true,
              ),
              const Divider(height: 16),
              _runWindowItem(
                isDark,
                timeWindow: '12:00 PM – 03:00 PM',
                temp: '${weather.currentTemp.round() + 4}°C',
                condition: 'High UV & Heat: Avoid',
                icon: Icons.warning_amber_rounded,
                isRecommended: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Wind Speed & Heat Alert
        Row(
          children: [
            Expanded(
              child: WeatherCard(
                title: 'WIND CONDITIONS',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${weather.windSpeed.round()}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('km/h', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$beaufort • $cardinal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weather.windSpeed < 25
                          ? 'Pleasant running breeze'
                          : 'High resistance headwind',
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
                title: 'HEAT & EXERTION',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.feelsLike.round()}°C',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: heatAlert.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      heatAlert.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: heatAlert.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weather.feelsLike > 32
                          ? 'Hydrate frequently 💧'
                          : 'Ideal workout thermal comfort',
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

  Widget _runWindowItem(
    bool isDark, {
    required String timeWindow,
    required String temp,
    required String condition,
    required IconData icon,
    required bool isRecommended,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isRecommended ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeWindow,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                condition,
                style: TextStyle(
                  fontSize: 12,
                  color: isRecommended
                      ? (isDark ? Colors.white60 : const Color(0xFF64748B))
                      : const Color(0xFFE53935),
                ),
              ),
            ],
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
    );
  }
}
