import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/ai_weather_service.dart';
import 'weather_provider.dart';

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final bool isFromFallback;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.isFromFallback = false,
  });
}

class AIAssistantNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final WeatherAIService _aiService;

  AIAssistantNotifier(this._aiService)
      : super(
          AsyncValue.data([
            ChatMessage(
              role: 'assistant',
              content:
                  'Hello! I am your AI Weather Intelligence Assistant 🌦️\n\nAsk me anything about how today\'s weather impacts your day, workouts, commute, what to wear, or travel plans.',
              timestamp: DateTime.now(),
            ),
          ]),
        );

  Future<void> askQuestion({
    required String question,
    required MausamDataBundle bundle,
  }) async {
    final currentList = state.valueOrNull ?? [];
    final userMessage = ChatMessage(
      role: 'user',
      content: question,
      timestamp: DateTime.now(),
    );

    // Append user message immediately and show loading
    final updatedList = [...currentList, userMessage];
    state = AsyncValue.data(updatedList);

    try {
      final contextMap = WeatherAIRequest.buildContext(
        weather: bundle.weather,
        airQuality: bundle.airQuality,
        cityName: bundle.location.cityName,
      );

      final history = updatedList.map((m) {
        return {'role': m.role, 'content': m.content};
      }).toList();

      final response = await _aiService.ask(
        WeatherAIRequest(
          question: question,
          weatherContext: contextMap,
          conversationHistory: history,
        ),
      );

      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: response.answer,
        timestamp: DateTime.now(),
        isFromFallback: response.isFromFallback,
      );

      state = AsyncValue.data([...updatedList, assistantMessage]);
    } catch (e) {
      final errorMessage = ChatMessage(
        role: 'assistant',
        content:
            '⚠️ I encountered an unexpected error processing that question. Please try asking in a slightly different way.',
        timestamp: DateTime.now(),
        isFromFallback: true,
      );
      state = AsyncValue.data([...updatedList, errorMessage]);
    }
  }

  void clearChat() {
    state = AsyncValue.data([
      ChatMessage(
        role: 'assistant',
        content:
            'Chat cleared. What else would you like to know about the weather today?',
        timestamp: DateTime.now(),
      ),
    ]);
  }
}

final weatherAIServiceProvider = Provider<WeatherAIService>((ref) {
  return HybridWeatherAIService();
});

final aiAssistantProvider =
    StateNotifierProvider<AIAssistantNotifier, AsyncValue<List<ChatMessage>>>(
        (ref) {
  final service = ref.watch(weatherAIServiceProvider);
  return AIAssistantNotifier(service);
});
