import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/packing_suggestions.dart';
import '../../core/utils/unit_converter.dart';
import '../../core/utils/weather_helpers.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/location_model.dart';
import '../../providers/unit_provider.dart';
import '../common/weather_card.dart';

class TravelerWidget extends ConsumerWidget {
  final WeatherModel weather;
  final List<LocationModel> savedCities;
  final Function(LocationModel)? onCitySelect;

  const TravelerWidget({
    super.key,
    required this.weather,
    required this.savedCities,
    this.onCitySelect,
  });

  bool _isFlightAlertNeeded() {
    return weather.precipitationProbability > 60 ||
        weather.windSpeed > 45 ||
        WeatherHelpers.isFog(weather.weatherCode) ||
        WeatherHelpers.isStorm(weather.weatherCode);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Personas.color(Personas.traveler);
    final unitSettings = ref.watch(unitSettingsProvider);
    final hasFlightDelayRisk = _isFlightAlertNeeded();

    final packingList = PackingSuggestions.getSuggestions(weather);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flight & Transit Weather Alert
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasFlightDelayRisk
                ? (isDark ? const Color(0xFF382319) : const Color(0xFFFFF3E0))
                : (isDark ? const Color(0xFF1E2838) : const Color(0xFFF3E5F5)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasFlightDelayRisk
                  ? const Color(0xFFFF9800)
                  : accent.withOpacity(0.4),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Text(
                hasFlightDelayRisk ? '⚠️' : '✈️',
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasFlightDelayRisk
                          ? 'Possible Flight / Travel Delays'
                          : 'Clear Skies for Flights & Transit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: hasFlightDelayRisk
                            ? const Color(0xFFE65100)
                            : (isDark ? const Color(0xFFCE93D8) : const Color(0xFF6A1B9A)),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasFlightDelayRisk
                          ? 'High winds or reduced visibility detected. Check flight status before airport departure.'
                          : 'No severe weather alerts impacting flights or train departures.',
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

        // Saved Destinations Carousel
        WeatherCard(
          title: 'SAVED DESTINATIONS',
          titleTrailing: const Text(
            'Tap to switch',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          child: SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: savedCities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final city = savedCities[i];
                // Sample simulated temperatures for quick preview
                final sampleTemps = [17.0, 24.0, 14.0, 28.0];
                final sampleEmojis = ['🌧️', '🌤️', '☀️', '⛅'];
                final temp = UnitConverter.formatTemp(sampleTemps[i % sampleTemps.length], unitSettings.tempUnit);
                final emoji = sampleEmojis[i % sampleEmojis.length];

                return InkWell(
                  onTap: () => onCitySelect?.call(city),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 130,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262D3D) : const Color(0xFFF8F9FD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 22)),
                            Text(
                              temp,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              city.cityName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              city.country.isNotEmpty ? city.country : 'Destination',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Packing Suggestions Card
        WeatherCard(
          title: 'SMART PACKING SUGGESTIONS',
          titleTrailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'For ${weather.cityName}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI luggage recommendations based on current temperature (${weather.currentTemp.round()}°C) and rain risk (${weather.precipitationProbability.round()}%):',
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: packingList.map((item) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2B2236)
                          : const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFE1BEE7)
                            : const Color(0xFF6A1B9A),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
