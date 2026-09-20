import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/unit_converter.dart';
import '../../providers/persona_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/unit_provider.dart';
import '../../providers/intelligence_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPersona = ref.watch(personaProvider);
    final userName = ref.watch(userNameProvider);
    final themeMode = ref.watch(themeModeProvider);
    final units = ref.watch(unitSettingsProvider);
    final alerts = ref.watch(alertPreferencesProvider);
    final accent = Personas.color(currentPersona);

    final cardBg = isDark ? const Color(0xFF1E2430) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings & Preferences',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          // Active Persona Card
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
                        'ACTIVE LIFESTYLE PERSONA',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
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

          // UNIT PREFERENCES SECTION
          _buildSectionHeader('MEASUREMENT UNITS'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Temperature Unit
                ListTile(
                  title: const Text('Temperature Unit', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Display temperatures in Celsius or Fahrenheit'),
                  trailing: SegmentedButton<TemperatureUnit>(
                    segments: const [
                      ButtonSegment(value: TemperatureUnit.celsius, label: Text('°C')),
                      ButtonSegment(value: TemperatureUnit.fahrenheit, label: Text('°F')),
                    ],
                    selected: {units.tempUnit},
                    onSelectionChanged: (set) {
                      ref.read(unitSettingsProvider.notifier).setTempUnit(set.first);
                    },
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // Wind Speed Unit
                ListTile(
                  title: const Text('Wind Speed', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Units for wind speed and gusts'),
                  trailing: DropdownButton<WindSpeedUnit>(
                    value: units.windUnit,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: WindSpeedUnit.kmh, child: Text('km/h')),
                      DropdownMenuItem(value: WindSpeedUnit.mph, child: Text('mph')),
                      DropdownMenuItem(value: WindSpeedUnit.ms, child: Text('m/s')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(unitSettingsProvider.notifier).setWindUnit(val);
                      }
                    },
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // Pressure Unit
                ListTile(
                  title: const Text('Barometric Pressure', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Atmospheric pressure metric'),
                  trailing: DropdownButton<PressureUnit>(
                    value: units.pressureUnit,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: PressureUnit.hpa, child: Text('hPa')),
                      DropdownMenuItem(value: PressureUnit.inhg, child: Text('inHg')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(unitSettingsProvider.notifier).setPressureUnit(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SMART ALERTS PREFERENCES
          _buildSectionHeader('WEATHER ALERT PREFERENCES'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildAlertSwitch(
                  title: 'Incoming Precipitation',
                  subtitle: 'Notify when rain or snow is predicted soon',
                  icon: Icons.umbrella_rounded,
                  iconColor: Colors.blueAccent,
                  value: alerts['rain'] ?? true,
                  onChanged: () => ref.read(alertPreferencesProvider.notifier).togglePreference('rain'),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildAlertSwitch(
                  title: 'Severe Storms & Thunder',
                  subtitle: 'High alert for thunderstorms and squalls',
                  icon: Icons.thunderstorm_rounded,
                  iconColor: Colors.deepPurpleAccent,
                  value: alerts['storm'] ?? true,
                  onChanged: () => ref.read(alertPreferencesProvider.notifier).togglePreference('storm'),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildAlertSwitch(
                  title: 'Extreme Heat (>38°C / 100°F)',
                  subtitle: 'High temperature safety warnings',
                  icon: Icons.whatshot_rounded,
                  iconColor: Colors.deepOrangeAccent,
                  value: alerts['extremeHeat'] ?? true,
                  onChanged: () => ref.read(alertPreferencesProvider.notifier).togglePreference('extremeHeat'),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildAlertSwitch(
                  title: 'Extreme Cold (<0°C / 32°F)',
                  subtitle: 'Frostbite and freezing warnings',
                  icon: Icons.ac_unit_rounded,
                  iconColor: Colors.cyanAccent,
                  value: alerts['extremeCold'] ?? true,
                  onChanged: () => ref.read(alertPreferencesProvider.notifier).togglePreference('extremeCold'),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildAlertSwitch(
                  title: 'High Air Pollution (AQI > 100)',
                  subtitle: 'Sensitive group respiratory warnings',
                  icon: Icons.air_rounded,
                  iconColor: Colors.orangeAccent,
                  value: alerts['aqi'] ?? true,
                  onChanged: () => ref.read(alertPreferencesProvider.notifier).togglePreference('aqi'),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildAlertSwitch(
                  title: 'Very High UV Index (UV ≥ 8)',
                  subtitle: 'Sunburn risk and sun protection advice',
                  icon: Icons.wb_sunny_rounded,
                  iconColor: Colors.amberAccent,
                  value: alerts['uv'] ?? true,
                  onChanged: () => ref.read(alertPreferencesProvider.notifier).togglePreference('uv'),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildAlertSwitch(
                  title: 'Dense Fog & Low Visibility',
                  subtitle: 'Commute and driving visibility alerts',
                  icon: Icons.blur_on_rounded,
                  iconColor: Colors.blueGrey,
                  value: alerts['fog'] ?? true,
                  onChanged: () => ref.read(alertPreferencesProvider.notifier).togglePreference('fog'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // QUICK NAVIGATION SHORTCUTS
          _buildSectionHeader('INTELLIGENCE SUITE SHORTCUTS'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_city_rounded, color: Colors.blueAccent),
                  title: const Text('My Places & Multi-City Matrix'),
                  subtitle: const Text('Compare weather side-by-side across saved places'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/locations'),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.map_rounded, color: Colors.tealAccent),
                  title: const Text('Interactive Weather Radar & Map'),
                  subtitle: const Text('Precipitation radar, wind streamlines & AQI overlays'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/map'),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.smart_toy_rounded, color: Colors.purpleAccent),
                  title: const Text('AI Weather Assistant Chat'),
                  subtitle: const Text('Natural language answers grounded in live forecasts'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/assistant'),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.flight_takeoff_rounded, color: Colors.amberAccent),
                  title: const Text('Smart Travel & Trip Planner'),
                  subtitle: const Text('Multi-day destination forecasts and packing checklist'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/travel'),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.insights_rounded, color: Colors.indigoAccent),
                  title: const Text('Weather Analytics & Photography'),
                  subtitle: const Text('Historical trends, golden hour & climate anomalies'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/analytics'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // APP PREFERENCES & LOCATION
          _buildSectionHeader('APPLICATION & SENSORS'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // User Name editor
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Display Name'),
                  subtitle: Text(userName),
                  trailing: const Icon(Icons.edit_outlined, size: 20),
                  onTap: () => _showNameDialog(context, ref, userName),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),

                // Dark Mode Toggle
                ListTile(
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
                const Divider(height: 1, indent: 56, endIndent: 16),

                // Refresh GPS Location
                ListTile(
                  leading: const Icon(Icons.my_location_rounded),
                  title: const Text('Refresh GPS Location'),
                  subtitle: const Text('Re-query device sensor for current coordinates'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ref.read(locationProvider.notifier).fetchCurrentLocation();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Detecting GPS location...')),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),

                // Clear Offline Cache
                ListTile(
                  leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                  title: const Text('Clear Offline Cache', style: TextStyle(color: Colors.redAccent)),
                  subtitle: const Text('Remove locally stored weather bundles and restart fresh'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _confirmClearCache(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ABOUT & ATTRIBUTION
          _buildSectionHeader('SYSTEM & ATTRIBUTION'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '🌤️ Mausam AI Intelligence Platform',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'v2.0.0',
                        style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '• Open-Meteo API: High-resolution NWP weather forecast & historical archives (CC BY 4.0).\n'
                  '• CAMS & GFS: Real-time global atmospheric air quality (AQI, PM2.5, PM10, Ozone, NO2).\n'
                  '• Open-Meteo Marine: Wave height, wave direction, swell periods & ocean sea temperatures.\n'
                  '• OpenStreetMap / Nominatim: Global geocoding and reverse location discovery.\n'
                  '• Hybrid AI Architecture: Deterministic on-device meteorological rule engine with seamless Gemini/OpenAI cloud intelligence.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildAlertSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required VoidCallback onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: (_) => onChanged(),
    );
  }

  void _confirmClearCache(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Weather Cache?'),
        content: const Text(
          'This will remove cached weather snapshots and force a fresh network sync on next refresh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref.read(storageServiceProvider).clearCache();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Offline weather cache cleared successfully!')),
                );
              }
            },
            child: const Text('Clear'),
          ),
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
