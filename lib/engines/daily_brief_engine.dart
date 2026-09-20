import '../data/models/weather_model.dart';
import '../data/models/air_quality_model.dart';
import '../core/constants/personas.dart';
import 'comfort_score_engine.dart';

class DailyBrief {
  final String greeting;
  final String headline;
  final List<String> bulletPoints;
  final int comfortScore;
  final String comfortLabel;

  const DailyBrief({
    required this.greeting,
    required this.headline,
    required this.bulletPoints,
    required this.comfortScore,
    required this.comfortLabel,
  });
}

class DailyBriefEngine {
  const DailyBriefEngine();

  static DailyBrief generate({
    required WeatherModel weather,
    required AirQualityModel airQuality,
    required String userName,
    required String persona,
  }) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning, $userName'
        : (hour < 17 ? 'Good afternoon, $userName' : 'Good evening, $userName');

    final comfort = ComfortScoreEngine.calculate(
      weather: weather,
      airQuality: airQuality,
    );

    final bullets = <String>[];

    // 1. Rain timing / probability
    if (weather.precipitationProbability > 60) {
      bullets.add('🌧️ Rain showers likely today (${weather.precipitationProbability.round()}% chance). Keep an umbrella handy.');
    } else if (weather.precipitationProbability > 30) {
      bullets.add('🌦️ Slight possibility of localized scattered drizzle (${weather.precipitationProbability.round()}%).');
    } else {
      bullets.add('🌤️ Dry conditions expected throughout the day.');
    }

    // 2. Solar UV & Sun exposure
    if (weather.uvIndex >= 8.0) {
      bullets.add('☀️ UV levels will be extreme midday (${weather.uvIndex.toStringAsFixed(1)}). SPF 50+ recommended.');
    } else if (weather.uvIndex >= 5.0) {
      bullets.add('☀️ Moderate UV levels (${weather.uvIndex.toStringAsFixed(1)}). Wear shades and sunscreen.');
    }

    // 3. Air Quality status
    if (airQuality.aqi > 120) {
      bullets.add('🌫️ AQI is elevated (${airQuality.aqi}). Sensitive individuals should minimize strenuous cardio.');
    } else if (airQuality.aqi <= 50) {
      bullets.add('🌿 Clean and refreshing air quality (${airQuality.aqi} AQI).');
    } else {
      bullets.add('💨 Moderate air quality (${airQuality.aqi} AQI).');
    }

    // 4. Best outdoor window
    if (weather.feelsLike > 30) {
      bullets.add('🏃 Best outdoor & workout window: 6:00 AM – 8:30 AM.');
    } else if (weather.feelsLike < 10) {
      bullets.add('🏃 Best outdoor & workout window: 1:00 PM – 3:30 PM (warmest hours).');
    } else {
      bullets.add('🏃 Great conditions for outdoor exercise most of the day.');
    }

    // 5. Persona-specific focal highlight
    switch (persona) {
      case Personas.commuter:
        if (weather.precipitationProbability > 40 || weather.weatherCode == 45) {
          bullets.add('🚗 Commute alert: Wet roads or fog may slow evening transit.');
        } else {
          bullets.add('🚗 Traffic forecast: Clear driving conditions expected.');
        }
        break;
      case Personas.fitness:
        bullets.add('👟 Running suitability: ${comfort.overallScore}/100. Hydrate well!');
        break;
      case Personas.agriculture:
        final soil = weather.daily.isNotEmpty ? weather.daily.first.soilMoisture : 30.0;
        bullets.add('🌾 Farm intelligence: Soil moisture at ${soil.round()}%. Evapotranspiration is active.');
        break;
      case Personas.family:
        bullets.add('👨‍👩‍👧 Family tip: Great afternoon for park outings if rain stays low.');
        break;
      case Personas.beach:
        bullets.add('🏖️ Shore forecast: Favorable coastal conditions today.');
        break;
      default:
        break;
    }

    final headline = '${weather.currentTemp.round()}°C • Feels like ${weather.feelsLike.round()}°C • ${comfort.label}';

    return DailyBrief(
      greeting: greeting,
      headline: headline,
      bulletPoints: bullets,
      comfortScore: comfort.overallScore,
      comfortLabel: comfort.label,
    );
  }
}
