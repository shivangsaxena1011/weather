import 'package:flutter/material.dart';
import '../../core/constants/personas.dart';

class PersonaHeader extends StatelessWidget {
  final String persona;
  final String userName;
  final String cityName;
  final VoidCallback onSettingsTap;
  final VoidCallback onPersonaTap;
  final VoidCallback onLocationTap;

  const PersonaHeader({
    super.key,
    required this.persona,
    required this.userName,
    required this.cityName,
    required this.onSettingsTap,
    required this.onPersonaTap,
    required this.onLocationTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Personas.color(persona);
    final emoji = Personas.icon(persona);
    final personaLabel = Personas.label(persona);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Location button with pin icon
            Semantics(
              button: true,
              label: 'Selected location: $cityName. Tap to search or change location',
              child: InkWell(
                onTap: onLocationTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cityName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Settings button
            IconButton(
              onPressed: onSettingsTap,
              icon: Icon(
                Icons.tune_rounded,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
              tooltip: 'Settings & Personas',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()}, $userName 👋',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personalized weather dashboard',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            // Persona badge (tappable to switch)
            Semantics(
              button: true,
              label: 'Active persona: $personaLabel. Tap to switch persona',
              child: InkWell(
                onTap: onPersonaTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: accent.withOpacity(0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        personaLabel,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
