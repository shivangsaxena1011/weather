import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/weather_helpers.dart';
import '../../data/models/location_model.dart';
import '../../providers/persona_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/home/persona_header.dart';
import '../../widgets/home/current_weather_hero.dart';
import '../../widgets/home/quick_stats_row.dart';
import '../../widgets/common/alert_banner.dart';
import '../../widgets/common/shimmer_loader.dart';
import '../../widgets/personas/health_widget.dart';
import '../../widgets/personas/fitness_widget.dart';
import '../../widgets/personas/beach_widget.dart';
import '../../widgets/personas/traveler_widget.dart';
import '../../widgets/personas/family_widget.dart';
import '../../widgets/personas/agriculture_widget.dart';
import '../../widgets/personas/commuter_widget.dart';
import '../../widgets/personas/event_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showCitySearchDialog(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController();
    final geocoding = ref.read(geocodingServiceProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setState) {
            List<LocationModel> results = [];
            bool searching = false;

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181F2C) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Search Any Global City',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'e.g. London, Mumbai, Dubai, Tokyo...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF222B3D) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (query) async {
                      if (query.trim().isEmpty) return;
                      setState(() => searching = true);
                      final res = await geocoding.searchCity(query);
                      setState(() {
                        results = res;
                        searching = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (searching)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (results.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final loc = results[i];
                          return ListTile(
                            leading: const Icon(Icons.location_city_rounded),
                            title: Text(loc.cityName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(loc.country),
                            onTap: () {
                              ref.read(locationProvider.notifier).setLocation(loc);
                              ref.read(savedCitiesProvider.notifier).addCity(loc);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final persona = ref.watch(personaProvider);
    final userName = ref.watch(userNameProvider);
    final locationAsync = ref.watch(locationProvider);
    final bundleAsync = ref.watch(weatherDataProvider);
    final savedCities = ref.watch(savedCitiesProvider);
    final accent = Personas.color(persona);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: accent,
          onRefresh: () async {
            ref.invalidate(weatherDataProvider);
            await ref.read(weatherDataProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Persona & User Header
                PersonaHeader(
                  persona: persona,
                  userName: userName,
                  cityName: locationAsync.valueOrNull?.cityName ?? 'Detecting location...',
                  onSettingsTap: () => context.push('/settings'),
                  onPersonaTap: () => context.push('/persona-picker'),
                  onLocationTap: () => _showCitySearchDialog(context, ref),
                ),
                const SizedBox(height: 18),

                // Data-driven content with Loading Shimmer
                bundleAsync.when(
                  loading: () => const Column(
                    children: [
                      ShimmerLoader(
                        width: double.infinity,
                        height: 200,
                        borderRadius: 28,
                      ),
                      SizedBox(height: 18),
                      ShimmerLoader(
                        width: double.infinity,
                        height: 70,
                        borderRadius: 16,
                      ),
                      SizedBox(height: 18),
                      ShimmerLoader(
                        width: double.infinity,
                        height: 250,
                        borderRadius: 20,
                      ),
                    ],
                  ),
                  error: (err, stack) => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A1C1C) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text('⚠️ Connection Issue', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        const Text('Unable to connect to weather service. Showing cached preview.'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => ref.refresh(weatherDataProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (bundle) {
                    final weather = bundle.weather;
                    final airQuality = bundle.airQuality;
                    final marine = bundle.marine;

                    final isStorm = WeatherHelpers.isStorm(weather.weatherCode);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Weather Hero (Tap goes to 7-day forecast)
                        CurrentWeatherHero(
                          weather: weather,
                          persona: persona,
                          onForecastTap: () => context.push('/forecast'),
                        ),
                        const SizedBox(height: 16),

                        // Severe Storm Banner (if active)
                        if (isStorm)
                          const AlertBanner(
                            title: 'Severe Storm Warning in Effect',
                            message: 'Thunderstorms and heavy localized precipitation detected. Stay indoors and avoid travel.',
                            severity: AlertSeverity.danger,
                          ),

                        // Quick Stats Row (AQI, UV, Rain, Visibility, Dew)
                        QuickStatsRow(
                          weather: weather,
                          airQuality: airQuality,
                          persona: persona,
                        ),
                        const SizedBox(height: 22),

                        // Section Divider
                        Row(
                          children: [
                            Text(
                              'PERSONALIZED INSIGHTS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Divider(
                                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Persona Specific Dynamic Widget
                        _buildPersonaWidget(
                          persona: persona,
                          weather: weather,
                          airQuality: airQuality,
                          marine: marine,
                          savedCities: savedCities,
                          onCitySelect: (city) {
                            ref.read(locationProvider.notifier).setLocation(city);
                          },
                        ),

                        const SizedBox(height: 36),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141923) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Today',
                  isSelected: true,
                  accent: accent,
                  onTap: () {},
                ),
                _navItem(
                  icon: Icons.calendar_month_rounded,
                  label: '7-Day',
                  isSelected: false,
                  accent: accent,
                  onTap: () => context.push('/forecast'),
                ),
                _navItem(
                  icon: Icons.tune_rounded,
                  label: 'Settings',
                  isSelected: false,
                  accent: accent,
                  onTap: () => context.push('/settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? accent : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? accent : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaWidget({
    required String persona,
    required dynamic weather,
    required dynamic airQuality,
    required dynamic marine,
    required List<LocationModel> savedCities,
    required Function(LocationModel) onCitySelect,
  }) {
    switch (persona) {
      case Personas.health:
        return HealthWidget(weather: weather, airQuality: airQuality);
      case Personas.fitness:
        return FitnessWidget(weather: weather);
      case Personas.beach:
        return BeachWidget(weather: weather, marine: marine);
      case Personas.traveler:
        return TravelerWidget(
          weather: weather,
          savedCities: savedCities,
          onCitySelect: onCitySelect,
        );
      case Personas.family:
        return FamilyWidget(weather: weather);
      case Personas.agriculture:
        return AgricultureWidget(weather: weather);
      case Personas.commuter:
        return CommuterWidget(weather: weather);
      case Personas.event:
        return EventWidget(weather: weather);
      default:
        return HealthWidget(weather: weather, airQuality: airQuality);
    }
  }
}
