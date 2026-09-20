import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/errors/weather_exceptions.dart';
import '../models/weather_model.dart';
import '../models/air_quality_model.dart';

class WeatherAIRequest {
  final String question;
  final Map<String, dynamic> weatherContext;
  final List<Map<String, String>> conversationHistory;

  const WeatherAIRequest({
    required this.question,
    required this.weatherContext,
    this.conversationHistory = const [],
  });

  static Map<String, dynamic> buildContext({
    required WeatherModel weather,
    required AirQualityModel airQuality,
    required String cityName,
  }) {
    return {
      'location': cityName,
      'temperature': weather.currentTemp.round(),
      'feelsLike': weather.feelsLike.round(),
      'humidity': weather.humidity.round(),
      'windSpeed': weather.windSpeed.round(),
      'uvIndex': weather.uvIndex,
      'precipitationProbability': weather.precipitationProbability.round(),
      'precipitation': weather.precipitation,
      'weatherCode': weather.weatherCode,
      'aqi': airQuality.aqi,
      'visibilityKm': (weather.visibility / 1000).toStringAsFixed(1),
      'forecast': weather.daily.take(5).map((d) {
        return {
          'date': d.date.toIso8601String().substring(0, 10),
          'tempMin': d.tempMin.round(),
          'tempMax': d.tempMax.round(),
          'rainProb': d.precipitationProbabilityMax.round(),
          'rainMm': d.precipitationSum,
        };
      }).toList(),
    };
  }
}

class WeatherAIResponse {
  final String answer;
  final List<String> suggestedQuestions;
  final bool isFromFallback;

  const WeatherAIResponse({
    required this.answer,
    this.suggestedQuestions = const [],
    this.isFromFallback = false,
  });
}

/// Abstract AI service definition allowing interchangeable providers.
abstract class WeatherAIService {
  Future<WeatherAIResponse> ask(WeatherAIRequest request);
}

/// Hybrid Weather AI Service: Uses configured external LLM (OpenAI/Gemini/Proxy)
/// if keys exist, and gracefully falls back to deterministic expert engine.
class HybridWeatherAIService implements WeatherAIService {
  final Dio _dio;
  final RuleBasedWeatherAIService _ruleFallback = const RuleBasedWeatherAIService();

  HybridWeatherAIService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 12),
              ),
            );

  @override
  Future<WeatherAIResponse> ask(WeatherAIRequest request) async {
    final geminiKey = dotenv.env['GEMINI_API_KEY'];
    final openAiKey = dotenv.env['OPENAI_API_KEY'];
    final proxyUrl = dotenv.env['AI_PROXY_URL'];

    if (geminiKey != null && geminiKey.isNotEmpty && !geminiKey.contains('your_')) {
      try {
        return await _askGemini(request, geminiKey);
      } catch (_) {
        // Gracefully degrade to rule-based expert engine
      }
    }

    if (openAiKey != null && openAiKey.isNotEmpty && !openAiKey.contains('your_')) {
      try {
        return await _askOpenAI(request, openAiKey);
      } catch (_) {
        // Gracefully degrade to rule-based expert engine
      }
    }

    if (proxyUrl != null && proxyUrl.isNotEmpty) {
      try {
        return await _askProxy(request, proxyUrl);
      } catch (_) {
        // Gracefully degrade
      }
    }

    // High quality deterministic domain expert response
    return _ruleFallback.ask(request);
  }

  Future<WeatherAIResponse> _askGemini(
      WeatherAIRequest request, String apiKey) async {
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    final prompt = _buildSystemPrompt(request);

    final response = await _dio.post(
      url,
      data: {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 500,
        }
      },
    );

    final candidates = response.data['candidates'] as List?;
    if (candidates != null && candidates.isNotEmpty) {
      final text =
          candidates[0]['content']['parts'][0]['text'] as String? ?? '';
      return WeatherAIResponse(
        answer: text.trim(),
        suggestedQuestions: _generateSuggestions(request.question),
        isFromFallback: false,
      );
    }
    throw const AIServiceError();
  }

  Future<WeatherAIResponse> _askOpenAI(
      WeatherAIRequest request, String apiKey) async {
    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      }),
      data: {
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': _buildSystemPrompt(request),
          },
          {'role': 'user', 'content': request.question},
        ],
        'temperature': 0.3,
        'max_tokens': 400,
      },
    );

    final choices = response.data['choices'] as List?;
    if (choices != null && choices.isNotEmpty) {
      final text = choices[0]['message']['content'] as String? ?? '';
      return WeatherAIResponse(
        answer: text.trim(),
        suggestedQuestions: _generateSuggestions(request.question),
        isFromFallback: false,
      );
    }
    throw const AIServiceError();
  }

  Future<WeatherAIResponse> _askProxy(
      WeatherAIRequest request, String proxyUrl) async {
    final response = await _dio.post(
      proxyUrl,
      data: {
        'question': request.question,
        'context': request.weatherContext,
      },
    );
    final text = response.data['answer'] as String? ?? '';
    return WeatherAIResponse(
      answer: text,
      suggestedQuestions: _generateSuggestions(request.question),
      isFromFallback: false,
    );
  }

  String _buildSystemPrompt(WeatherAIRequest request) {
    return '''
You are Mausam AI Weather Intelligence Assistant.
You interpret weather data and deliver concise, actionable, and friendly recommendations.
CRITICAL RULES:
1. All weather facts and numbers MUST come ONLY from the provided JSON context below. Never invent or hallucinate temperatures, precipitation, or air quality.
2. Answer the user's specific practical question concisely in 2-4 sentences with markdown formatting.
3. If giving clothing, travel, or activity advice, base it directly on temperature, humidity, rain probability, and UV index.

CURRENT WEATHER CONTEXT:
${jsonEncode(request.weatherContext)}

USER QUESTION:
${request.question}
''';
  }

  List<String> _generateSuggestions(String question) {
    return [
      'What should I wear today?',
      'Will it rain this afternoon?',
      'Is today good for an outdoor run?',
      'Why does it feel hotter than the temperature?',
    ];
  }
}

/// Deterministic Rule-Based Expert Engine that operates offline or when external AI is not configured.
class RuleBasedWeatherAIService implements WeatherAIService {
  const RuleBasedWeatherAIService();

  @override
  Future<WeatherAIResponse> ask(WeatherAIRequest request) async {
    final q = request.question.toLowerCase().trim();
    final ctx = request.weatherContext;

    final location = ctx['location']?.toString() ?? 'your location';
    final temp = (ctx['temperature'] as num? ?? 25).round();
    final feelsLike = (ctx['feelsLike'] as num? ?? 26).round();
    final humidity = (ctx['humidity'] as num? ?? 50).round();
    final wind = (ctx['windSpeed'] as num? ?? 10).round();
    final rainProb = (ctx['precipitationProbability'] as num? ?? 0).round();
    final uv = (ctx['uvIndex'] as num? ?? 5).toDouble();
    final aqi = (ctx['aqi'] as num? ?? 50).round();

    String answer;

    // 1. Rain / Umbrella Intent
    if (q.contains('rain') ||
        q.contains('umbrella') ||
        q.contains('wet') ||
        q.contains('shower')) {
      if (rainProb >= 60) {
        answer =
            '🌧️ **Yes, carry an umbrella!**\n\nIn $location, rain probability is elevated at **$rainProb%**. Scattered showers or localized downpours are likely today. Keep water-resistant footwear and an umbrella handy.';
      } else if (rainProb >= 30) {
        answer =
            '🌦️ **Moderate chance of rain ($rainProb%)** in $location.\n\nWhile steady rain is not guaranteed, carrying a compact folding umbrella is a smart precaution, especially for late afternoon.';
      } else {
        answer =
            '☀️ **No umbrella needed!**\n\nRain probability in $location is very low (**$rainProb%**). Skies should remain mostly dry throughout today.';
      }
    }
    // 2. Running / Outdoor Fitness Intent
    else if (q.contains('run') ||
        q.contains('jog') ||
        q.contains('workout') ||
        q.contains('exercise') ||
        q.contains('cycling') ||
        q.contains('walk')) {
      if (temp > 32 || feelsLike > 35) {
        answer =
            '🏃 **Early morning or late evening recommended.**\n\nIn $location, midday apparent temperature reaches **$feelsLike°C** with high UV (**$uv**). For running or intense cardio, schedule your session between **6:00 AM – 8:00 AM** and carry plenty of electrolytes.';
      } else if (rainProb > 65) {
        answer =
            '🏋️ **Gym or indoor session recommended.**\n\nRain probability is high (**$rainProb%**), making roads and paths slick. An indoor workout or gym training is safer today.';
      } else if (aqi > 150) {
        answer =
            '😷 **Indoor exercise advised.**\n\nAir quality in $location is unhealthy (**$aqi AQI**). Deep cardio breathing outdoors may cause respiratory strain. Gym or home workouts are best.';
      } else {
        answer =
            '✅ **Great conditions for an outdoor workout!**\n\nTemperature is **$temp°C** (feels like **$feelsLike°C**) with low rain risk (**$rainProb%**). Morning hours (6:30 AM – 9:00 AM) or sunset hours offer optimal thermal comfort.';
      }
    }
    // 3. Outfit / What to wear Intent
    else if (q.contains('wear') ||
        q.contains('dress') ||
        q.contains('clothes') ||
        q.contains('outfit') ||
        q.contains('jacket')) {
      final items = <String>[];
      if (feelsLike >= 28) {
        items.add('👕 Light breathable cotton T-shirt');
        items.add('🩳 Chinos or shorts');
      } else if (feelsLike >= 18) {
        items.add('👕 Comfortable cotton top');
        items.add('👖 Light jeans or trousers');
      } else if (feelsLike >= 10) {
        items.add('🧥 Light jacket or pullover');
        items.add('👖 Regular trousers');
      } else {
        items.add('🧥 Warm insulated coat & scarf');
        items.add('🧤 Warm gloves');
      }

      if (rainProb > 40) {
        items.add('☂️ Compact umbrella');
        items.add('🥾 Water-resistant shoes');
      }
      if (uv >= 6) {
        items.add('🧴 SPF 50+ Sunscreen');
        items.add('🕶️ UV sunglasses & cap');
      }

      final itemsList = items.map((it) => '• $it').join('\n');
      final thermalDesc = feelsLike >= 28 ? 'warm' : (feelsLike < 14 ? 'chilly' : 'moderate');
      answer =
          '👕 **Outfit Advice for $location ($temp°C, feels like $feelsLike°C):**\n\n$itemsList\n\n*Thermal index is $thermalDesc.*';
    }
    // 4. Feels-Like explanation
    else if (q.contains('feel') ||
        q.contains('hotter') ||
        q.contains('colder') ||
        q.contains('why')) {
      final diff = (feelsLike - temp).abs();
      if (feelsLike > temp) {
        answer =
            '🌡️ **Why does it feel like $feelsLike°C when actual temp is $temp°C?**\n\nIn $location, relative humidity is **$humidity%**. Higher humidity slows down sweat evaporation from your skin, reducing natural body cooling and making the air feel **$diff°C warmer** than the thermometer reads.';
      } else if (feelsLike < temp) {
        answer =
            '💨 **Wind Chill Effect:**\n\nThe temperature is **$temp°C**, but feels like **$feelsLike°C** because wind speeds of **$wind km/h** accelerate body heat dissipation, creating a noticeable cooling effect on exposed skin.';
      } else {
        answer =
            '⚖️ **Actual and feels-like temperature match ($temp°C).**\n\nBalanced humidity ($humidity%) and calm wind ($wind km/h) allow the perceived temperature to align naturally with the true ambient temperature in $location.';
      }
    }
    // 5. Outdoor Event / Party Intent
    else if (q.contains('event') ||
        q.contains('party') ||
        q.contains('outdoor') ||
        q.contains('picnic') ||
        q.contains('wedding')) {
      if (rainProb >= 50) {
        answer =
            '⚠️ **Rain contingency advised for outdoor events.**\n\nRain probability is **$rainProb%** with potential precipitation. Having an indoor backup venue or rainproof canopy is strongly recommended.';
      } else if (wind >= 35) {
        answer =
            '💨 **High wind alert for event setup.**\n\nWind gusts up to **$wind km/h** could disturb temporary tents, banners, and lightweight decor. Anchor structures securely.';
      } else {
        answer =
            '🎉 **Favorable weather for outdoor events!**\n\nWith only **$rainProb%** rain risk, gentle breeze (**$wind km/h**), and **$temp°C** temperatures, conditions in $location are very supportive for gatherings.';
      }
    }
    // 6. Travel / Commute Intent
    else if (q.contains('travel') ||
        q.contains('trip') ||
        q.contains('drive') ||
        q.contains('college') ||
        q.contains('commute')) {
      final travelNotice = rainProb > 50
          ? 'Plan an extra 15–20 minutes for traffic delays due to wet road conditions.'
          : 'Road and transit conditions look clear with minimal weather disruptions expected.';
      answer =
          '🚗 **Travel & Transit Outlook for $location:**\n\n• Current Temp: **$temp°C** (Feels like **$feelsLike°C**)\n• Rain Probability: **$rainProb%**\n• Wind: **$wind km/h**\n• Air Quality: **$aqi AQI**\n\n$travelNotice';
    }
    // 7. General Weather Summary
    else {
      answer =
          '🌦️ **Weather Intelligence for $location:**\n\n• Temperature: **$temp°C** (Feels like **$feelsLike°C**)\n• Humidity: **$humidity%** • Wind: **$wind km/h**\n• Rain Risk: **$rainProb%** • UV Index: **$uv**\n• Air Quality: **$aqi AQI**\n\nOverall, today offers ${feelsLike >= 30 ? 'warm and humid' : (feelsLike <= 15 ? 'cool and brisk' : 'mild and pleasant')} conditions.';
    }

    return WeatherAIResponse(
      answer: answer,
      suggestedQuestions: [
        'What should I wear today?',
        'Will it rain this afternoon?',
        'Is today good for an outdoor run?',
        'Why does it feel hotter than the temperature?',
      ],
      isFromFallback: true,
    );
  }
}
