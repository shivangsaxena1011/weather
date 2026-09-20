import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/personas.dart';
import '../../data/models/weather_model.dart';
import '../../providers/weather_provider.dart';
import '../../providers/persona_provider.dart';
import '../../providers/intelligence_provider.dart';
import '../../widgets/common/weather_card.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _selectedDays = 7; // 7, 30, 90, 365
  List<DailyWeather> _historicalDays = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistoricalData();
    });
  }

  Future<void> _loadHistoricalData() async {
    final bundle = ref.read(weatherDataProvider).valueOrNull;
    if (bundle == null) return;

    setState(() => _loading = true);
    final repo = ref.read(weatherRepositoryProvider);
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _selectedDays));
    final endDate = now.subtract(const Duration(days: 1));

    try {
      final days = await repo.getHistoricalDailyWeather(
        latitude: bundle.location.latitude,
        longitude: bundle.location.longitude,
        startDate: startDate,
        endDate: endDate,
      );
      setState(() {
        _historicalDays = days;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  ({String goldenHourMorning, String goldenHourEvening, String blueHourDusk, int photoScore})
      _computeSunMetrics(DailyWeather? today) {
    if (today == null) {
      return (
        goldenHourMorning: '6:00 AM – 6:45 AM',
        goldenHourEvening: '5:45 PM – 6:30 PM',
        blueHourDusk: '6:30 PM – 6:50 PM',
        photoScore: 82,
      );
    }

    final sunrise = today.sunrise;
    final sunset = today.sunset;

    final gmStart = DateFormat('h:mm a').format(sunrise);
    final gmEnd =
        DateFormat('h:mm a').format(sunrise.add(const Duration(minutes: 45)));

    final geStart = DateFormat('h:mm a')
        .format(sunset.subtract(const Duration(minutes: 45)));
    final geEnd = DateFormat('h:mm a').format(sunset);

    final bDuskStart = geEnd;
    final bDuskEnd =
        DateFormat('h:mm a').format(sunset.add(const Duration(minutes: 25)));

    int score = 85;
    if (today.weatherCode == 1 || today.weatherCode == 2) {
      score += 10; // dramatic clouds
    } else if (today.precipitationSum > 2) {
      score -= 30; // rain
    }

    return (
      goldenHourMorning: '$gmStart – $gmEnd',
      goldenHourEvening: '$geStart – $geEnd',
      blueHourDusk: '$bDuskStart – $bDuskEnd',
      photoScore: score.clamp(0, 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final persona = ref.watch(personaProvider);
    final accent = Personas.color(persona);
    final bundle = ref.watch(weatherDataProvider).valueOrNull;
    final anomalies = ref.watch(weatherAnomalyProvider);

    final todayDaily =
        bundle?.weather.daily.isNotEmpty == true ? bundle!.weather.daily.first : null;
    final sunInfo = _computeSunMetrics(todayDaily);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Analytics & Sun',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeframe Segmented Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2430) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _timeframeButton(7, '7 Days', accent),
                  _timeframeButton(30, '30 Days', accent),
                  _timeframeButton(90, '3 Months', accent),
                  _timeframeButton(365, '1 Year', accent),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Temperature Trend Chart
            WeatherCard(
              title: 'HISTORICAL TEMPERATURE TREND (${_selectedDays}D)',
              child: _loading
                  ? const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SizedBox(
                      height: 190,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (val) => FlLine(
                              color: isDark ? Colors.white10 : Colors.black12,
                              strokeWidth: 0.8,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (v, _) => Text(
                                  '${v.round()}°',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                getTitlesWidget: (v, _) {
                                  final idx = v.toInt();
                                  if (idx >= 0 &&
                                      idx < _historicalDays.length &&
                                      idx % (_selectedDays > 30 ? 15 : 2) == 0) {
                                    return Text(
                                      DateFormat('MM/dd').format(_historicalDays[idx].date),
                                      style: const TextStyle(fontSize: 9),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // Max Temp Line
                            LineChartBarData(
                              spots: _historicalDays.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value.tempMax);
                              }).toList(),
                              isCurved: true,
                              color: accent,
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: accent.withOpacity(0.12),
                              ),
                            ),
                            // Min Temp Line
                            LineChartBarData(
                              spots: _historicalDays.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value.tempMin);
                              }).toList(),
                              isCurved: true,
                              color: const Color(0xFF0284C7),
                              barWidth: 2.0,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Sun & Golden Hour Intelligence Card
            WeatherCard(
              title: 'SUN & PHOTOGRAPHY INTELLIGENCE',
              titleTrailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Photo Score ${sunInfo.photoScore}/100',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _sunMetric(
                        '🌅 Sunrise',
                        todayDaily != null
                            ? DateFormat('h:mm a').format(todayDaily.sunrise)
                            : '6:15 AM',
                        const Color(0xFFF59E0B),
                      ),
                      _sunMetric(
                        '🌇 Sunset',
                        todayDaily != null
                            ? DateFormat('h:mm a').format(todayDaily.sunset)
                            : '6:45 PM',
                        const Color(0xFFEA580C),
                      ),
                      _sunMetric(
                        '⏳ Daylight',
                        todayDaily != null
                            ? '${todayDaily.sunset.difference(todayDaily.sunrise).inHours}h ${todayDaily.sunset.difference(todayDaily.sunrise).inMinutes % 60}m'
                            : '12h 30m',
                        accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 8),
                  _lightingRow(
                    '📸 Golden Hour (Morning)',
                    sunInfo.goldenHourMorning,
                    'Soft warm directional lighting with elongated shadows',
                  ),
                  const SizedBox(height: 8),
                  _lightingRow(
                    '📸 Golden Hour (Evening)',
                    sunInfo.goldenHourEvening,
                    'Vibrant amber hue ideal for portraits and landscapes',
                  ),
                  const SizedBox(height: 8),
                  _lightingRow(
                    '🌌 Blue Hour (Dusk)',
                    sunInfo.blueHourDusk,
                    'Rich deep indigo sky backdrop perfect for architecture',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Weather Anomaly Detection Section
            if (anomalies.isNotEmpty) ...[
              WeatherCard(
                title: 'STATISTICAL ANOMALY DETECTION',
                titleTrailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Active Deviations',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
                child: Column(
                  children: anomalies.map((a) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF141923)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(a.emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      a.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14),
                                    ),
                                    Text(
                                      a.deviationText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: a.isAboveAverage
                                            ? Colors.orange
                                            : Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  a.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white60
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeframeButton(int days, String label, Color accent) {
    final isSelected = _selectedDays == days;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedDays = days);
          _loadHistoricalData();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sunMetric(String title, String time, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }

  Widget _lightingRow(String title, String time, String tip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
            Text(time,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0284C7))),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          tip,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
