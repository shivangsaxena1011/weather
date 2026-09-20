import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/personas.dart';
import '../../providers/ai_assistant_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/persona_provider.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickPrompts = [
    'Should I carry an umbrella?',
    'What should I wear today?',
    'Is today good for a run?',
    'Why does it feel hotter than the temp?',
    'Any alerts for my daily commute?',
    'Is this evening good for an event?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendQuestion(String text) {
    if (text.trim().isEmpty) return;
    final bundle = ref.read(weatherDataProvider).valueOrNull;
    if (bundle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weather data is still loading...')),
      );
      return;
    }

    _textController.clear();
    ref
        .read(aiAssistantProvider.notifier)
        .askQuestion(question: text.trim(), bundle: bundle);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final persona = ref.watch(personaProvider);
    final accent = Personas.color(persona);
    final chatState = ref.watch(aiAssistantProvider);
    final messages = chatState.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🤖', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Weather Assistant',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Chat',
            onPressed: () {
              ref.read(aiAssistantProvider.notifier).clearChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Intelligence context badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: accent.withOpacity(isDark ? 0.15 : 0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 16, color: accent),
                const SizedBox(width: 6),
                Text(
                  'Grounded directly in real-time sensor & forecast data',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[i];
                final isUser = msg.role == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? accent
                          : (isDark
                              ? const Color(0xFF1E2430)
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.content,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.45,
                            color: isUser
                                ? Colors.white
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isUser
                                  ? Colors.white70
                                  : (isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Suggested quick prompts carousel
          Container(
            height: 42,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final prompt = _quickPrompts[i];
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  backgroundColor: isDark
                      ? const Color(0xFF1E2430)
                      : const Color(0xFFF1F5F9),
                  side: BorderSide(
                    color: accent.withOpacity(0.3),
                    width: 1,
                  ),
                  onPressed: () => _sendQuestion(prompt),
                );
              },
            ),
          ),

          // Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141923) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendQuestion,
                    decoration: InputDecoration(
                      hintText: 'Ask about rain, runs, outfits, travel...',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E2430)
                          : const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: accent,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => _sendQuestion(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
