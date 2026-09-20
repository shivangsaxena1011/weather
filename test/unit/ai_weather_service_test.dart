import 'package:flutter_test/flutter_test.dart';
import 'package:mausam/data/services/ai_weather_service.dart';

void main() {
  group('RuleBasedWeatherAIService Tests', () {
    const service = RuleBasedWeatherAIService();

    test('Answers umbrella query correctly when rain is high', () async {
      const request = WeatherAIRequest(
        question: 'Should I take an umbrella today?',
        weatherContext: {
          'location': 'Seattle',
          'temperature': 15,
          'feelsLike': 14,
          'humidity': 85,
          'windSpeed': 18,
          'precipitationProbability': 80,
          'precipitation': 5.0,
          'uvIndex': 2.0,
          'aqi': 30,
        },
      );

      final response = await service.ask(request);
      expect(response.answer, contains('umbrella'));
      expect(response.answer.toLowerCase(), contains('yes'));
      expect(response.suggestedQuestions, isNotEmpty);
    });

    test('Answers workout query warning about high AQI', () async {
      const request = WeatherAIRequest(
        question: 'Can I go for a run outside?',
        weatherContext: {
          'location': 'Delhi',
          'temperature': 28,
          'feelsLike': 30,
          'humidity': 55,
          'windSpeed': 10,
          'precipitationProbability': 5,
          'precipitation': 0.0,
          'uvIndex': 6.0,
          'aqi': 240, // Unhealthy AQI
        },
      );

      final response = await service.ask(request);
      expect(response.answer.toLowerCase(), anyOf(contains('indoor'), contains('respiratory'), contains('aqi')));
    });

    test('Answers outfit query with appropriate clothing items', () async {
      const request = WeatherAIRequest(
        question: 'What should I wear today?',
        weatherContext: {
          'location': 'Denver',
          'temperature': 5,
          'feelsLike': 2,
          'humidity': 60,
          'windSpeed': 25,
          'precipitationProbability': 10,
          'precipitation': 0.0,
          'uvIndex': 3.0,
          'aqi': 25,
        },
      );

      final response = await service.ask(request);
      expect(response.answer.toLowerCase(), anyOf(contains('jacket'), contains('warm'), contains('fleece'), contains('coat')));
    });

    test('Handles general / unknown query with informative overview', () async {
      const request = WeatherAIRequest(
        question: 'Tell me about the weather',
        weatherContext: {
          'location': 'Tokyo',
          'temperature': 20,
          'feelsLike': 20,
          'humidity': 50,
          'windSpeed': 12,
          'precipitationProbability': 0,
          'precipitation': 0.0,
          'uvIndex': 4.0,
          'aqi': 40,
        },
      );

      final response = await service.ask(request);
      expect(response.answer, isNotEmpty);
      expect(response.answer, contains('Tokyo'));
    });
  });
}
