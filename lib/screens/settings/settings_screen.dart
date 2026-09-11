import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/personas.dart';
import '../../providers/persona_provider.dart';
import '../../providers/location_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPersona = ref.watch(personaProvider);
    final userName = ref.watch(userNameProvider);
    final themeMode = ref.watch(themeModeProvider);
    final accent = Personas.color(currentPersona);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings & Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          // Current Persona Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: accent.withOpacity(isDark ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(0.4), width: 1.2),
            ),
            child: Row(
              children: [
                Text(
                  Personas.icon(currentPersona),
                  style: const TextStyle(fontSize: 34),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Persona',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        Personas.label(currentPersona),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => context.push('/persona-picker'),
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // User Preferences Section
          const Text(
            'USER PREFERENCES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          // User Name editor
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: isDark ? const Color(0xFF1E2430) : Colors.white,
            leading: const Icon(Icons.person_outline_rounded),
            title: const Text('Display Name'),
            subtitle: Text(userName),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _showNameDialog(context, ref, userName),
          ),
          const SizedBox(height: 10),

          // Dark Mode Toggle
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: isDark ? const Color(0xFF1E2430) : Colors.white,
            leading: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            ),
            title: const Text('Theme Mode'),
            subtitle: Text(themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode'),
            trailing: Switch(
              value: isDark,
              activeColor: accent,
              onChanged: (_) =>
                  ref.read(themeModeProvider.notifier).toggleTheme(),
            ),
          ),
          const SizedBox(height: 10),

          // Refresh Location
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: isDark ? const Color(0xFF1E2430) : Colors.white,
            leading: const Icon(Icons.my_location_rounded),
            title: const Text('Refresh GPS Location'),
            subtitle: const Text('Re-detect coordinates from device sensor'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ref.read(locationProvider.notifier).fetchCurrentLocation();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Detecting GPS location...')),
              );
            },
          ),
          const SizedBox(height: 24),

          // About & Credits Section
          const Text(
            'DATA SOURCES & ATTRIBUTION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2430) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🌤️ Mausam v1.0.0',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  'Weather, Air Quality (AQI), and Marine data are provided by Open-Meteo under CC BY 4.0. Geocoding powered by Open-Meteo & Nominatim (OpenStreetMap). All APIs used are 100% free with no private key requirement for essential weather features.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Display Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(userNameProvider.notifier)
                    .setUserName(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
