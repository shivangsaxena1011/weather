import 'dart:math' as math;
import '../data/models/weather_model.dart';

enum AnomalySeverity { mild, notable, severe }

class WeatherAnomaly {
  final String metric;
  final String title;
  final String deviationText;
  final double zScore;
  final AnomalySeverity severity;
  final String description;
  final bool isAboveAverage;
  final String emoji;

  const WeatherAnomaly({
    required this.metric,
    required this.title,
    required this.deviationText,
    required this.zScore,
    required this.severity,
    required this.description,
    required this.isAboveAverage,
    required this.emoji,
  });
}

class WeatherAnomalyDetector {
  const WeatherAnomalyDetector();

  /// Detects statistical anomalies in temperature, precipitation, and wind
  /// compared to the 14-day forecast window baseline.
  static List<WeatherAnomaly> detect(WeatherModel weather) {
    final anomalies = <WeatherAnomaly>[];
    if (weather.daily.length < 5) return anomalies;

    // 1. Temperature Anomaly (Max Temp across 14-day window)
    final tempValues = weather.daily.map((d) => d.tempMax).toList();
    final tempAnomaly = _checkMetricAnomaly(
      currentValue: weather.currentTemp,
      baselineValues: tempValues,
      metricName: 'Temperature',
      unit: '°C',
      hotEmoji: '🔥',
      coldEmoji: '❄️',
      notableThreshold: 1.5,
      severeThreshold: 2.2,
      explanationGenerator: (dev, above) => above
          ? 'Current temperature is noticeably warmer than the 14-day baseline.'
          : 'Current temperature is notably colder than the 14-day baseline.',
    );
    if (tempAnomaly != null) anomalies.add(tempAnomaly);

    // 2. Wind Speed Anomaly
    final windValues = weather.daily.map((d) => d.windSpeedMax).toList();
    final windAnomaly = _checkMetricAnomaly(
      currentValue: weather.windSpeed,
      baselineValues: windValues,
      metricName: 'Wind Speed',
      unit: ' km/h',
      hotEmoji: '💨',
      coldEmoji: '🍃',
      notableThreshold: 1.6,
      severeThreshold: 2.4,
      explanationGenerator: (dev, above) => above
          ? 'Wind gusts are significantly elevated compared to the 14-day average.'
          : 'Wind is exceptionally calm compared to recent average patterns.',
    );
    if (windAnomaly != null) anomalies.add(windAnomaly);

    // 3. Precipitation Probability Anomaly
    final rainValues = weather.daily.map((d) => d.precipitationProbabilityMax).toList();
    final rainAnomaly = _checkMetricAnomaly(
      currentValue: weather.precipitationProbability,
      baselineValues: rainValues,
      metricName: 'Rain Probability',
      unit: '%',
      hotEmoji: '🌧️',
      coldEmoji: '☀️',
      notableThreshold: 1.8,
      severeThreshold: 2.5,
      explanationGenerator: (dev, above) => above
          ? 'Unusually elevated rain probability compared to the period average.'
          : 'Drier conditions than typical for this period.',
    );
    if (rainAnomaly != null) anomalies.add(rainAnomaly);

    return anomalies;
  }

  static WeatherAnomaly? _checkMetricAnomaly({
    required double currentValue,
    required List<double> baselineValues,
    required String metricName,
    required String unit,
    required String hotEmoji,
    required String coldEmoji,
    required double notableThreshold,
    required double severeThreshold,
    required String Function(double dev, bool above) explanationGenerator,
  }) {
    if (baselineValues.isEmpty) return null;

    final mean = baselineValues.reduce((a, b) => a + b) / baselineValues.length;
    final variance = baselineValues
            .map((x) => math.pow(x - mean, 2))
            .reduce((a, b) => a + b) /
        baselineValues.length;
    final stdDev = math.sqrt(variance);

    if (stdDev < 0.5) return null; // Negligible variance

    final zScore = (currentValue - mean) / stdDev;
    final absZ = zScore.abs();

    if (absZ < notableThreshold) return null; // Within normal variation

    final isAbove = zScore > 0;
    final diff = (currentValue - mean).abs();
    final sign = isAbove ? '+' : '-';
    final deviationText = '$sign${diff.toStringAsFixed(1)}$unit vs 14-day avg';

    final severity = absZ >= severeThreshold
        ? AnomalySeverity.severe
        : AnomalySeverity.notable;

    return WeatherAnomaly(
      metric: metricName,
      title: '$metricName Statistical Anomaly',
      deviationText: deviationText,
      zScore: zScore,
      severity: severity,
      description: explanationGenerator(diff, isAbove),
      isAboveAverage: isAbove,
      emoji: isAbove ? hotEmoji : coldEmoji,
    );
  }
}
