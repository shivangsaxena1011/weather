import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engines/comfort_score_engine.dart';
import '../engines/activity_intelligence_engine.dart';
import '../engines/smart_alert_engine.dart';
import '../engines/daily_brief_engine.dart';
import '../engines/outfit_recommendation_engine.dart';
import '../engines/anomaly_detection_engine.dart';
import 'weather_provider.dart';
import 'persona_provider.dart';

/// Provides the computed Weather Comfort Score (0-100) and factor breakdown.
final comfortScoreProvider = Provider<ComfortScoreResult?>((ref) {
  final bundleAsync = ref.watch(weatherDataProvider);
  final bundle = bundleAsync.valueOrNull;
  if (bundle == null) return null;

  return ComfortScoreEngine.calculate(
    weather: bundle.weather,
    airQuality: bundle.airQuality,
  );
});

/// Provides ranked activity suitability recommendations.
final activityIntelligenceProvider =
    Provider<List<ActivityRecommendation>>((ref) {
  final bundleAsync = ref.watch(weatherDataProvider);
  final bundle = bundleAsync.valueOrNull;
  if (bundle == null) return [];

  return ActivityRecommendationEngine.evaluateAll(
    weather: bundle.weather,
    airQuality: bundle.airQuality,
  );
});

/// Provides smart weather alerts based on thresholds and user preferences.
final smartAlertsProvider = Provider<List<SmartAlert>>((ref) {
  final bundleAsync = ref.watch(weatherDataProvider);
  final bundle = bundleAsync.valueOrNull;
  if (bundle == null) return [];

  return SmartAlertEngine.evaluate(
    weather: bundle.weather,
    airQuality: bundle.airQuality,
  );
});

/// Provides the personalized daily briefing.
final dailyBriefProvider = Provider<DailyBrief?>((ref) {
  final bundleAsync = ref.watch(weatherDataProvider);
  final persona = ref.watch(personaProvider);
  final userName = ref.watch(userNameProvider);
  final bundle = bundleAsync.valueOrNull;
  if (bundle == null) return null;

  return DailyBriefEngine.generate(
    weather: bundle.weather,
    airQuality: bundle.airQuality,
    userName: userName,
    persona: persona,
  );
});

/// Provides outfit recommendations.
final outfitRecommendationProvider = Provider<List<OutfitItem>>((ref) {
  final bundleAsync = ref.watch(weatherDataProvider);
  final bundle = bundleAsync.valueOrNull;
  if (bundle == null) return [];

  return OutfitRecommendationEngine.recommend(bundle.weather);
});

/// Provides detected weather anomalies.
final weatherAnomalyProvider = Provider<List<WeatherAnomaly>>((ref) {
  final bundleAsync = ref.watch(weatherDataProvider);
  final bundle = bundleAsync.valueOrNull;
  if (bundle == null) return [];

  return WeatherAnomalyDetector.detect(bundle.weather);
});
