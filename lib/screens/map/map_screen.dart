import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/personas.dart';
import '../../data/models/location_model.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/air_quality_model.dart';
import '../../providers/weather_provider.dart';
import '../../providers/persona_provider.dart';
import '../../widgets/common/weather_card.dart';

abstract class WeatherMapLayer {
  String get id;
  String get name;
  IconData get icon;
  String get unit;
  String get description;
  List<({double value, Color color, String label})> get legendScale;
  Color getColorForValue(double value);
}

class TemperatureMapLayer implements WeatherMapLayer {
  @override
  String get id => 'temp';
  @override
  String get name => 'Temperature';
  @override
  IconData get icon => Icons.thermostat_rounded;
  @override
  String get unit => '°C';
  @override
  String get description => 'Thermal distribution across coordinates';

  @override
  List<({double value, Color color, String label})> get legendScale => [
        (value: 0, color: const Color(0xFF3B82F6), label: '<0°C'),
        (value: 15, color: const Color(0xFF10B981), label: '15°C'),
        (value: 25, color: const Color(0xFFFBBF24), label: '25°C'),
        (value: 35, color: const Color(0xFFF97316), label: '35°C'),
        (value: 45, color: const Color(0xFFEF4444), label: '>40°C'),
      ];

  @override
  Color getColorForValue(double value) {
    if (value <= 5) return const Color(0xFF3B82F6);
    if (value <= 18) return const Color(0xFF10B981);
    if (value <= 28) return const Color(0xFFFBBF24);
    if (value <= 36) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }
}

class PrecipitationMapLayer implements WeatherMapLayer {
  @override
  String get id => 'rain';
  @override
  String get name => 'Rain Radar';
  @override
  IconData get icon => Icons.water_drop_rounded;
  @override
  String get unit => '%';
  @override
  String get description => 'Precipitation probability & storm radar';

  @override
  List<({double value, Color color, String label})> get legendScale => [
        (value: 0, color: Colors.transparent, label: '0%'),
        (value: 20, color: const Color(0xFF67E8F9), label: '20%'),
        (value: 50, color: const Color(0xFF0284C7), label: '50%'),
        (value: 80, color: const Color(0xFF1D4ED8), label: '80%'),
        (value: 100, color: const Color(0xFF7E22CE), label: 'Storm'),
      ];

  @override
  Color getColorForValue(double value) {
    if (value < 10) return Colors.transparent;
    if (value <= 30) return const Color(0xFF67E8F9);
    if (value <= 60) return const Color(0xFF0284C7);
    if (value <= 85) return const Color(0xFF1D4ED8);
    return const Color(0xFF7E22CE);
  }
}

class WindMapLayer implements WeatherMapLayer {
  @override
  String get id => 'wind';
  @override
  String get name => 'Wind Stream';
  @override
  IconData get icon => Icons.air_rounded;
  @override
  String get unit => 'km/h';
  @override
  String get description => 'Atmospheric wind vectors & surface stream';

  @override
  List<({double value, Color color, String label})> get legendScale => [
        (value: 5, color: const Color(0xFF86EFAC), label: 'Calm'),
        (value: 20, color: const Color(0xFFFCD34D), label: 'Moderate'),
        (value: 40, color: const Color(0xFFFB923C), label: 'Strong'),
        (value: 60, color: const Color(0xFFF43F5E), label: 'Gale'),
      ];

  @override
  Color getColorForValue(double value) {
    if (value <= 10) return const Color(0xFF86EFAC);
    if (value <= 25) return const Color(0xFFFCD34D);
    if (value <= 45) return const Color(0xFFFB923C);
    return const Color(0xFFF43F5E);
  }
}

class AqiMapLayer implements WeatherMapLayer {
  @override
  String get id => 'aqi';
  @override
  String get name => 'Air Quality';
  @override
  IconData get icon => Icons.blur_on_rounded;
  @override
  String get unit => 'AQI';
  @override
  String get description => 'Atmospheric particulate and gas dispersion';

  @override
  List<({double value, Color color, String label})> get legendScale => [
        (value: 25, color: const Color(0xFF10B981), label: 'Good'),
        (value: 50, color: const Color(0xFFFBBF24), label: 'Moderate'),
        (value: 100, color: const Color(0xFFF97316), label: 'Unhealthy'),
        (value: 150, color: const Color(0xFFEF4444), label: 'Very Poor'),
        (value: 250, color: const Color(0xFF7E22CE), label: 'Hazardous'),
      ];

  @override
  Color getColorForValue(double value) {
    if (value <= 35) return const Color(0xFF10B981);
    if (value <= 75) return const Color(0xFFFBBF24);
    if (value <= 120) return const Color(0xFFF97316);
    if (value <= 180) return const Color(0xFFEF4444);
    return const Color(0xFF7E22CE);
  }
}

class WeatherMapScreen extends ConsumerStatefulWidget {
  const WeatherMapScreen({super.key});

  @override
  ConsumerState<WeatherMapScreen> createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends ConsumerState<WeatherMapScreen>
    with SingleTickerProviderStateMixin {
  final List<WeatherMapLayer> _layers = [
    TemperatureMapLayer(),
    PrecipitationMapLayer(),
    WindMapLayer(),
    AqiMapLayer(),
  ];

  late WeatherMapLayer _activeLayer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _activeLayer = _layers[0];
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final persona = ref.watch(personaProvider);
    final accent = Personas.color(persona);
    final bundle = ref.watch(weatherDataProvider).valueOrNull;
    final location = bundle?.location ?? LocationModel.defaultLocation();
    final weather = bundle?.weather;
    final aqi = bundle?.airQuality;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Radar & Map',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Simulated Interactive Map Canvas
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
              child: CustomPaint(
                painter: _MapCanvasPainter(
                  activeLayer: _activeLayer,
                  weather: weather,
                  aqi: aqi,
                  pulseFactor: _pulseController.value,
                  isDark: isDark,
                  accent: accent,
                ),
              ),
            ),
          ),

          // Layer Switcher Chips at the Top
          Positioned(
            top: 16,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF1E2430) : Colors.white)
                    .withOpacity(0.92),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _layers.map((layer) {
                  final isSelected = _activeLayer.id == layer.id;
                  return InkWell(
                    onTap: () => setState(() => _activeLayer = layer),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accent.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? accent : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            layer.icon,
                            size: 16,
                            color: isSelected ? accent : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            layer.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? accent
                                  : (isDark
                                      ? Colors.white70
                                      : const Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Legend and Location Info Card at Bottom
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Layer Legend Scale
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF1E2430) : Colors.white)
                        .withOpacity(0.90),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_activeLayer.name.toUpperCase()} SCALE',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _activeLayer.description,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _activeLayer.legendScale.map((item) {
                          return Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: 6,
                                  color: item.color,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.label,
                                  style: const TextStyle(fontSize: 9.5),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Location Weather Summary Card
                WeatherCard(
                  title: 'CURRENT SENSOR OVERLAY: ${location.cityName.toUpperCase()}',
                  titleTrailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Live GPS Pin',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricCell(
                          'Coords',
                          '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}',
                          accent),
                      _metricCell(
                          'Temp',
                          '${weather?.currentTemp.round() ?? 25}°C',
                          const Color(0xFF10B981)),
                      _metricCell(
                          'Rain Prob',
                          '${weather?.precipitationProbability.round() ?? 10}%',
                          const Color(0xFF0284C7)),
                      _metricCell('Air Quality',
                          '${aqi?.aqi ?? 50} AQI', const Color(0xFFF59E0B)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCell(String label, String val, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  final WeatherMapLayer activeLayer;
  final WeatherModel? weather;
  final AirQualityModel? aqi;
  final double pulseFactor;
  final bool isDark;
  final Color accent;

  _MapCanvasPainter({
    required this.activeLayer,
    required this.weather,
    required this.aqi,
    required this.pulseFactor,
    required this.isDark,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white10 : Colors.black12)
      ..strokeWidth = 0.8;

    // Draw coordinate grid lines
    const step = 45.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw simulated thermal or radar heat circles
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final heatPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);

    double value = 25.0;
    if (activeLayer.id == 'temp') {
      value = weather?.currentTemp ?? 25.0;
    } else if (activeLayer.id == 'rain') {
      value = weather?.precipitationProbability ?? 20.0;
    } else if (activeLayer.id == 'wind') {
      value = weather?.windSpeed ?? 15.0;
    } else if (activeLayer.id == 'aqi') {
      value = aqi?.aqi.toDouble() ?? 55.0;
    }

    final layerColor = activeLayer.getColorForValue(value);

    // Primary weather contour ring
    heatPaint.color = layerColor.withOpacity(0.35 + (pulseFactor * 0.15));
    canvas.drawCircle(center, 120 + (pulseFactor * 20), heatPaint);

    // Secondary contour
    heatPaint.color = layerColor.withOpacity(0.55);
    canvas.drawCircle(center, 70, heatPaint);

    // Coordinate Pin marker
    final pinCenter = center;
    final pinPaint = Paint()..color = accent;
    canvas.drawCircle(pinCenter, 8, pinPaint);

    final ringPaint = Paint()
      ..color = accent.withOpacity(1.0 - pulseFactor)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(pinCenter, 14 + (pulseFactor * 22), ringPaint);
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) => true;
}
