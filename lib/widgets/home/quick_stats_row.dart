import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/aqi_formatter.dart';
import '../../core/utils/unit_converter.dart';
import '../../core/utils/weather_helpers.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/air_quality_model.dart';
import '../../providers/unit_provider.dart';
import '../common/stat_chip.dart';

class QuickStatsRow extends ConsumerWidget {
  final WeatherModel weather;
  final AirQualityModel airQuality;
  final String persona;

  const QuickStatsRow({
    super.key,
    required this.weather,
    required this.airQuality,
    required this.persona,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Personas.color(persona);
    final unitSettings = ref.watch(unitSettingsProvider);
    final aqiColor = AqiFormatter.color(airQuality.aqi);
    final aqiLabel = AqiFormatter.label(airQuality.aqi);
    final visibilityKm = (weather.visibility / 1000).toStringAsFixed(1);
    final uvValue = weather.uvIndex.toStringAsFixed(1);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          StatChip(
            label: 'Air Quality',
            value: '${airQuality.aqi}',
            unit: '($aqiLabel)',
            icon: Icons.air_rounded,
            color: aqiColor,
          ),
          const SizedBox(width: 10),
          StatChip(
            label: 'UV Index',
            value: uvValue,
            unit: '(${WeatherHelpers.uvLabel(weather.uvIndex)})',
            icon: Icons.wb_sunny_rounded,
            color: const Color(0xFFFF9800),
          ),
          const SizedBox(width: 10),
          StatChip(
            label: 'Rain Prob',
            value: '${weather.precipitationProbability.round()}',
            unit: '%',
            icon: Icons.water_drop_outlined,
            color: const Color(0xFF29B6F6),
          ),
          const SizedBox(width: 10),
          StatChip(
            label: 'Visibility',
            value: visibilityKm,
            unit: 'km',
            icon: Icons.visibility_outlined,
            color: const Color(0xFF26A69A),
          ),
          const SizedBox(width: 10),
          StatChip(
            label: 'Dew Point',
            value: '${UnitConverter.convertTemp(weather.dewPoint, unitSettings.tempUnit).round()}',
            unit: unitSettings.tempUnit == TemperatureUnit.fahrenheit ? '°F' : '°C',
            icon: Icons.grain_rounded,
            color: accent,
          ),
        ],
      ),
    );
  }
}
