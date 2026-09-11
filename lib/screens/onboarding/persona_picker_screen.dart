import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/personas.dart';
import '../../providers/persona_provider.dart';

class PersonaPickerScreen extends ConsumerStatefulWidget {
  final bool isFromSettings;

  const PersonaPickerScreen({
    super.key,
    this.isFromSettings = false,
  });

  @override
  ConsumerState<PersonaPickerScreen> createState() =>
      _PersonaPickerScreenState();
}

class _PersonaPickerScreenState extends ConsumerState<PersonaPickerScreen> {
  String? _selected;

  final Map<String, ({String title, String subtitle, String emoji, Color color})>
      _personaDetails = {
    Personas.health: (
      title: 'Health-Conscious',
      subtitle: 'AQI, pollen counts, UV index, and humidity for allergy & asthma care',
      emoji: '🏥',
      color: const Color(0xFF4CAF50),
    ),
    Personas.fitness: (
      title: 'Outdoor Fitness',
      subtitle: 'Sunrise/sunset, best running hours, wind speed, and workout comfort',
      emoji: '🏃',
      color: const Color(0xFFFF5722),
    ),
    Personas.beach: (
      title: 'Beachgoer & Surfer',
      subtitle: 'Sea conditions, tide times, wave height, and water temperature',
      emoji: '🏄',
      color: const Color(0xFF03A9F4),
    ),
    Personas.traveler: (
      title: 'Frequent Traveler',
      subtitle: 'Saved destinations, flight alerts, and smart AI packing tips',
      emoji: '✈️',
      color: const Color(0xFF9C27B0),
    ),
    Personas.family: (
      title: 'Parent & Family',
      subtitle: 'School commute conditions, rain warnings, and outdoor play scores',
      emoji: '👨‍👩‍👧',
      color: const Color(0xFFFF9800),
    ),
    Personas.agriculture: (
      title: 'Agriculture & Garden',
      subtitle: 'Soil moisture, rainfall charts, frost alerts, and planting advice',
      emoji: '🌱',
      color: const Color(0xFF795548),
    ),
    Personas.commuter: (
      title: 'Daily Commuter',
      subtitle: 'Highway visibility, storm alerts, fog warnings, and traffic weather',
      emoji: '🚗',
      color: const Color(0xFF607D8B),
    ),
    Personas.event: (
      title: 'Event Planner',
      subtitle: 'Extended forecast, outdoor comfort index, and rain probabilities',
      emoji: '🎉',
      color: const Color(0xFFE91E63),
    ),
  };

  @override
  void initState() {
    super.initState();
    _selected = ref.read(personaProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Your Persona',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                'Mausam personalizes your home screen with curated widgets and alerts matched to your daily routine.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                itemCount: Personas.all.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final pKey = Personas.all[i];
                  final p = _personaDetails[pKey]!;
                  final isSelected = _selected == pKey;

                  return InkWell(
                    onTap: () {
                      setState(() => _selected = pKey);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? p.color.withOpacity(isDark ? 0.25 : 0.10)
                            : (isDark
                                ? const Color(0xFF1E2430)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? p.color
                              : (isDark
                                  ? Colors.white12
                                  : const Color(0xFFE2E8F0)),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: p.color.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: p.color.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              p.emoji,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.title,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  p.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white60
                                        : const Color(0xFF64748B),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: isSelected ? p.color : Colors.grey.shade400,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    if (_selected != null) {
                      await ref
                          .read(personaProvider.notifier)
                          .setPersona(_selected!);
                      final storage = ref.read(storageServiceProvider);
                      await storage.setOnboardingComplete();
                    }
                    if (context.mounted) {
                      if (widget.isFromSettings) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    }
                  },
                  child: const Text(
                    'Apply & Go to Dashboard 🚀',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
