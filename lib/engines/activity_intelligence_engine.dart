import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/weather_model.dart';
import '../data/models/air_quality_model.dart';

enum ActivityCategory {
  running,
  walking,
  cycling,
  gym,
  outdoorSports,
  photography,
  hiking,
  outdoorEvents,
  travel,
  commuting,
}

class ActivityRecommendation {
  final ActivityCategory category;
  final String title;
  final String emoji;
  final int score;
  final String status;
  final String bestTime;
  final String avoidTime;
  final List<String> reasons;
  final List<String> warnings;

  const ActivityRecommendation({
    required this.category,
    required this.title,
    required this.emoji,
    required this.score,
    required this.status,
    required this.bestTime,
    required this.avoidTime,
    required this.reasons,
    required this.warnings,
  });

  Color get color {
    if (score >= 80) return const Color(0xFF10B981); // Emerald
    if (score >= 65) return const Color(0xFF0284C7); // Blue
    if (score >= 50) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }
}

class ActivityRecommendationEngine {
  const ActivityRecommendationEngine();

  static List<ActivityRecommendation> evaluateAll({
    required WeatherModel weather,
    required AirQualityModel airQuality,
  }) {
    return [
      _evaluateRunning(weather, airQuality),
      _evaluateCycling(weather, airQuality),
      _evaluateWalking(weather, airQuality),
      _evaluateHiking(weather, airQuality),
      _evaluateOutdoorSports(weather, airQuality),
      _evaluatePhotography(weather),
      _evaluateOutdoorEvents(weather, airQuality),
      _evaluateCommuting(weather),
      _evaluateTravel(weather),
      _evaluateGym(weather, airQuality),
    ];
  }

  static ActivityRecommendation _evaluateRunning(
      WeatherModel weather, AirQualityModel aqi) {
    int score = 100;
    final reasons = <String>[];
    final warnings = <String>[];

    final temp = weather.feelsLike;
    final wind = weather.windSpeed;
    final rain = weather.precipitationProbability;
    final uv = weather.uvIndex;
    final aqiVal = aqi.aqi;

    if (temp > 30) {
      score -= 30;
      warnings.add('High apparent temperature (${temp.round()}°C)');
    } else if (temp > 26) {
      score -= 15;
      reasons.add('Warm thermal load');
    } else if (temp < 6) {
      score -= 25;
      warnings.add('Chilly conditions (${temp.round()}°C)');
    } else {
      reasons.add('Comfortable running temperature');
    }

    if (rain > 50) {
      score -= 35;
      warnings.add('High chance of rain (${rain.round()}%)');
    } else if (rain > 25) {
      score -= 15;
      reasons.add('Moderate rain risk');
    }

    if (wind > 30) {
      score -= 20;
      warnings.add('Gusty headwinds (${wind.round()} km/h)');
    }

    if (aqiVal > 100) {
      score -= 30;
      warnings.add('Poor air quality ($aqiVal AQI)');
    } else if (aqiVal <= 50) {
      reasons.add('Crisp, clean air');
    }

    if (uv > 7) {
      warnings.add('Peak UV hazard (UV ${uv.toStringAsFixed(1)})');
    }

    final s = score.clamp(0, 100);
    return ActivityRecommendation(
      category: ActivityCategory.running,
      title: 'Running & Jogging',
      emoji: '🏃',
      score: s,
      status: _scoreStatus(s),
      bestTime: '6:00 AM – 8:30 AM',
      avoidTime: '12:00 PM – 4:00 PM',
      reasons: reasons,
      warnings: warnings,
    );
  }

  static ActivityRecommendation _evaluateCycling(
      WeatherModel weather, AirQualityModel aqi) {
    int score = 100;
    final reasons = <String>[];
    final warnings = <String>[];

    final wind = weather.windSpeed;
    final rain = weather.precipitationProbability;
    final temp = weather.currentTemp;

    if (wind > 35) {
      score -= 40;
      warnings.add('Dangerous crosswinds (${wind.round()} km/h)');
    } else if (wind > 20) {
      score -= 20;
      reasons.add('Moderate wind resistance');
    } else {
      reasons.add('Low wind resistance');
    }

    if (rain > 40) {
      score -= 35;
      warnings.add('Slick roads expected from precipitation');
    }

    if (temp > 34 || temp < 5) {
      score -= 25;
      warnings.add('Extreme outdoor temperature');
    }

    final s = score.clamp(0, 100);
    return ActivityRecommendation(
      category: ActivityCategory.cycling,
      title: 'Cycling & Biking',
      emoji: '🚴',
      score: s,
      status: _scoreStatus(s),
      bestTime: '6:30 AM – 9:00 AM',
      avoidTime: '1:00 PM – 4:30 PM',
      reasons: reasons,
      warnings: warnings,
    );
  }

  static ActivityRecommendation _evaluateWalking(
      WeatherModel weather, AirQualityModel aqi) {
    int score = 95;
    final reasons = <String>[];
    final warnings = <String>[];

    if (weather.precipitationProbability > 60) {
      score -= 35;
      warnings.add('Rain likely; umbrella needed');
    } else {
      reasons.add('Clear pathways');
    }

    if (weather.feelsLike > 35) {
      score -= 30;
      warnings.add('High heat index');
    }

    if (aqi.aqi > 150) {
      score -= 35;
      warnings.add('Hazardous particulate level');
    }

    final s = score.clamp(0, 100);
    return ActivityRecommendation(
      category: ActivityCategory.walking,
      title: 'Brisk Walking & Stroll',
      emoji: '🚶',
      score: s,
      status: _scoreStatus(s),
      bestTime: '7:00 AM – 9:30 AM / 6:00 PM – 8:00 PM',
      avoidTime: '12:00 PM – 3:30 PM',
      reasons: reasons,
      warnings: warnings,
    );
  }

  static ActivityRecommendation _evaluateHiking(
      WeatherModel weather, AirQualityModel aqi) {
    int score = 95;
    final reasons = <String>[];
    final warnings = <String>[];

    if (weather.precipitationProbability > 40) {
      score -= 40;
      warnings.add('Muddy trails and slip hazard');
    }
    if (weather.visibility < 5000) {
      score -= 25;
      warnings.add('Low visibility on peaks');
    } else {
      reasons.add('Good trail visibility');
    }
    if (weather.uvIndex > 7) {
      warnings.add('Intense alpine UV exposure');
    }

    final s = score.clamp(0, 100);
    return ActivityRecommendation(
      category: ActivityCategory.hiking,
      title: 'Hiking & Trekking',
      emoji: '🥾',
      score: s,
      status: _scoreStatus(s),
      bestTime: 'Early Morning (Daybreak)',
      avoidTime: 'Afternoon thunderstorms',
      reasons: reasons,
      warnings: warnings,
    );
  }

  static ActivityRecommendation _evaluateOutdoorSports(
      WeatherModel weather, AirQualityModel aqi) {
    int score = 90;
    final reasons = <String>[];
    final warnings = <String>[];

    if (weather.precipitation > 0 || weather.precipitationProbability > 50) {
      score -= 45;
      warnings.add('Wet pitch / court conditions');
    }
    if (weather.windSpeed > 30) {
      score -= 25;
      warnings.add('High wind impacts ball trajectory');
    }
    if (weather.feelsLike > 33) {
      score -= 25;
      warnings.add('Heat exhaustion risk');
    }

    final s = score.clamp(0, 100);
    return ActivityRecommendation(
      category: ActivityCategory.outdoorSports,
      title: 'Outdoor Team Sports',
      emoji: '⚽',
      score: s,
      status: _scoreStatus(s),
      bestTime: '4:30 PM – 6:30 PM',
      avoidTime: '11:00 AM – 3:00 PM',
      reasons: reasons,
      warnings: warnings,
    );
  }

  static ActivityRecommendation _evaluatePhotography(WeatherModel weather) {
    int score = 85;
    final reasons = <String>[];
    final warnings = <String>[];

    if (weather.weatherCode == 1 || weather.weatherCode == 2) {
      score += 10;
      reasons.add('Dynamic cloud structure for dramatic sky photography');
    } else if (weather.weatherCode == 0) {
      reasons.add('Clean crisp sunlight');
    } else if (weather.weatherCode >= 61) {
      score -= 20;
      warnings.add('Camera moisture protection required');
    }

    if (weather.visibility > 9000) {
      reasons.add('High landscape clarity (>9 km)');
    }

    final sunriseStr = weather.daily.isNotEmpty
        ? DateFormat('h:mm a').format(weather.daily.first.sunrise)
        : '6:15 AM';
    final sunsetStr = weather.daily.isNotEmpty
        ? DateFormat('h:mm a').format(weather.daily.first.sunset)
        : '6:30 PM';

    final s = score.clamp(0, 100);
    return ActivityRecommendation(
      category: ActivityCategory.photography,
      title: 'Outdoor Photography',
      emoji: '📸',
      score: s,
      status: _scoreStatus(s),
      bestTime: 'Golden Hours ($sunriseStr & $sunsetStr)',
      avoidTime: 'Flat harsh midday sun (12:00 PM – 2:00 PM)',
      reasons: reasons,
      warnings: warnings,
    );
  }

  static ActivityRecommendation _evaluateOutdoorEvents(
      WeatherModel weather, AirQualityModel aqi) {
    int score = 90;
    final reasons = <String>[];
    final warnings = <String>[];

    if (weather.precipitationProbability > 35) {
      score -= 40;
      warnings.add('Rain probability > 35%. Canopy recommended.');
    }
    if (weather.windSpeed > 30) {
      score -= 25;
      warnings.add('Wind gusts may affect tents and banners');
    }
    if (weather.feelsLike > 32) {
      score -= 20;
      warnings.add('Provide misting fans & hydration');
    }

    final s = score.clamp(0, 100);
    return ActivityRecommendation(
      category: ActivityCategory.outdoorEvents,
      title: 'Events & Gatherings',
      emoji: '🎉',
      score: s,
      status: _scoreStatus(s),
      bestTime: '5:00 PM – 9:00 PM',
      avoidTime: 'Peak Heat (1:00 PM – 4:00 PM)',
      reasons: reasons,
      warnings: warnings,
    );
  }

  static ActivityRecommendation _evaluateCommuting(WeatherModel weather) {
    int score = 90;
    final reasons = <String>[];
    final warnings = <String>[];

    if (weather.weatherCode == 45 || weather.weatherCode == 48) {
      score -= 35;
      warnings.add('Heavy fog reducing roadway visibility');
    }
    if (weather.precipitationProbability > 60) {
      score -= 30;
      warnings.add('Expect slowdowns and hydroplaning risks');
    } else {
      reasons.add('Standard traffic flow expected');
    }

    final s = score.clamp(0, 100);
    return ActivityRecommendation(
      category: ActivityCategory.commuting,
      title: 'Daily Commuting',
      emoji: '🚗',
      score: s,
      status: _scoreStatus(s),
      bestTime: 'Depart 15 min early during rain',
      avoidTime: 'Peak rush hour in inclement weather',
      reasons: reasons,
      warnings: warnings,
    );
  }

  static ActivityRecommendation _evaluateTravel(WeatherModel weather) {
    int score = 92;
    final reasons = <String>[];
    final warnings = <String>[];

    if (weather.weatherCode >= 95) {
      score -= 50;
      warnings.add('Thunderstorm ground stops possible');
    }
    if (weather.visibility < 3000) {
      score -= 30;
      warnings.add('Low runway visibility flight delay risk');
    } else {
      reasons.add('Smooth flying and transit outlook');
    }

    final s = score.clamp(0, 100);
    return ActivityRecommendation(
      category: ActivityCategory.travel,
      title: 'Travel & Flights',
      emoji: '✈️',
      score: s,
      status: _scoreStatus(s),
      bestTime: 'Morning departures typically encounter fewer weather delays',
      avoidTime: 'Late afternoon storm windows',
      reasons: reasons,
      warnings: warnings,
    );
  }

  static ActivityRecommendation _evaluateGym(
      WeatherModel weather, AirQualityModel aqi) {
    // Gym is inverse of harsh weather (great when weather is bad outside!)
    int score = 80;
    final reasons = <String>[];
    final warnings = <String>[];

    if (weather.feelsLike > 32 ||
        weather.feelsLike < 8 ||
        weather.precipitationProbability > 50 ||
        aqi.aqi > 100) {
      score = 98;
      reasons.add('Indoor climate controlled setting is ideal today');
    } else {
      score = 75;
      reasons.add('Good option, though outdoor weather is also pleasant');
    }

    return ActivityRecommendation(
      category: ActivityCategory.gym,
      title: 'Indoor Gym & Fitness',
      emoji: '🏋️',
      score: score,
      status: _scoreStatus(score),
      bestTime: 'Anytime (Climate Controlled)',
      avoidTime: 'None',
      reasons: reasons,
      warnings: warnings,
    );
  }

  static String _scoreStatus(int score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Moderate';
    return 'Challenging';
  }
}
