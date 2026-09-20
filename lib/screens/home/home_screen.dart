import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/weather_helpers.dart';
import '../../core/utils/unit_converter.dart';
import '../../data/models/location_model.dart';
import '../../providers/persona_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/intelligence_provider.dart';
import '../../providers/unit_provider.dart';
import '../../widgets/home/persona_header.dart';
import '../../widgets/home/current_weather_hero.dart';
import '../../widgets/home/quick_stats_row.dart';
import '../../widgets/home/comfort_score_card.dart';
import '../../widgets/home/daily_brief_card.dart';
import '../../widgets/home/activity_intelligence_card.dart';
import '../../widgets/home/outfit_recommendation_card.dart';
import '../../widgets/home/ai_ask_bar.dart';
import '../../widgets/common/alert_banner.dart';
import '../../widgets/common/shimmer_loader.dart';
import '../../widgets/common/weather_card.dart';
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Search Any Global City',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.bookmarks_outlined, size: 16),
                        label: const Text('My Places'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.push('/locations');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'e.g. London, Mumbai, Dubai, Tokyo...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF222B3D)
                          : const Color(0xFFF1F5F9),
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
                            title: Text(loc.cityName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text('${loc.state ?? ''} ${loc.country}'),
                            onTap: () {
                              ref
                                  .read(locationProvider.notifier)
                                  .setLocation(loc);
                              ref
                                  .read(savedCitiesProvider.notifier)
                                  .addCity(loc);
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

  void _showInsightsSheet(BuildContext context, Color accent, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
                'Weather Intelligence Hub',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: accent.withOpacity(0.15),
                  child: const Text('📊', style: TextStyle(fontSize: 20)),
                ),
                title: const Text('Weather Analytics & Sun',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Historical trend charts, golden hour, anomalies'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/analytics');
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF0284C7).withOpacity(0.15),
                  child: const Text('✈️', style: TextStyle(fontSize: 20)),
                ),
                title: const Text('Travel Weather Planner',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Trip forecasts and AI packing suggestions'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/travel');
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                  child: const Text('📍', style: TextStyle(fontSize: 20)),
                ),
                title: const Text('My Places & Comparison',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Bookmark cities and compare side-by-side'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/locations');
                },
              ),
            ],
          ),
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
    final unitSettings = ref.watch(unitSettingsProvider);
    final accent = Personas.color(persona);

    // Intelligence Providers
    final comfortScore = ref.watch(comfortScoreProvider);
    final dailyBrief = ref.watch(dailyBriefProvider);
    final smartAlerts = ref.watch(smartAlertsProvider);
    final activities = ref.watch(activityIntelligenceProvider);
    final outfits = ref.watch(outfitRecommendationProvider);

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
                  cityName: locationAsync.valueOrNull?.cityName ??
                      'Detecting location...',
                  onSettingsTap: () => context.push('/settings'),
                  onPersonaTap: () => context.push('/persona-picker'),
                  onLocationTap: () => _showCitySearchDialog(context, ref),
                ),
                const SizedBox(height: 12),

                // Data-driven content
                bundleAsync.when(
                  loading: () => const Column(
                    children: [
                      ShimmerLoader(
                        width: double.infinity,
                        height: 200,
                        borderRadius: 28,
                      ),
                      SizedBox(height: 16),
                      ShimmerLoader(
                        width: double.infinity,
                        height: 90,
                        borderRadius: 20,
                      ),
                      SizedBox(height: 16),
                      ShimmerLoader(
                        width: double.infinity,
                        height: 160,
                        borderRadius: 20,
                      ),
                    ],
                  ),
                  error: (err, stack) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A1C1C)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 40, color: Colors.redAccent),
                        const SizedBox(height: 10),
                        const Text(
                          'Connection Issue',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          err.toString().contains('Rate limit')
                              ? 'Weather service rate limit reached. Please wait a minute and retry.'
                              : 'Unable to reach weather servers. Please verify your internet connection or retry.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(weatherDataProvider),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Retry Network'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  data: (bundle) {
                    final weather = bundle.weather;
                    final airQuality = bundle.airQuality;
                    final marine = bundle.marine;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Offline Notice & Last Updated Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (bundle.isOffline)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cloud_off_rounded,
                                        size: 13, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Text(
                                      'Offline Mode (Cached)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Text(
                              'Updated ${bundle.updatedAgoString}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Current Weather Hero (Dynamic Weather UI)
                        CurrentWeatherHero(
                          weather: weather,
                          persona: persona,
                          onForecastTap: () => context.push('/forecast'),
                        ),
                        const SizedBox(height: 14),

                        // Active Smart Weather Alerts Banner
                        if (smartAlerts.isNotEmpty) ...[
                          ...smartAlerts.map((alert) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AlertBanner(
                                title: '${alert.emoji} ${alert.title}',
                                message: '${alert.message} Tip: ${alert.actionTip}',
                                severity: alert.severity,
                              ),
                            );
                          }),
                        ],

                        // Weather Comfort Score Card
                        if (comfortScore != null) ...[
                          ComfortScoreCard(
                            result: comfortScore,
                            accent: accent,
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Today's Personalized Brief Card
                        if (dailyBrief != null) ...[
                          DailyBriefCard(
                            brief: dailyBrief,
                            accent: accent,
                          ),
                          const SizedBox(height: 14),
                        ],

                        // 24-Hour Hourly Timeline Scrub
                        WeatherCard(
                          title: 'HOURLY TEMPERATURE TIMELINE (24H)',
                          child: SizedBox(
                            height: 110,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: weather.hourly.take(24).length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final h = weather.hourly[i];
                                final hourStr = i == 0
                                    ? 'Now'
                                    : '${h.time.hour % 12 == 0 ? 12 : h.time.hour % 12} ${h.time.hour >= 12 ? 'PM' : 'AM'}';
                                final emoji =
                                    WeatherHelpers.codeToEmoji(h.weatherCode);
                                final tempStr = UnitConverter.formatTemp(
                                    h.temperature, unitSettings.tempUnit);

                                return Container(
                                  width: 68,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: i == 0
                                        ? accent.withOpacity(isDark ? 0.25 : 0.12)
                                        : (isDark
                                            ? const Color(0xFF141923)
                                            : const Color(0xFFF1F5F9)),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: i == 0
                                          ? accent
                                          : (isDark
                                              ? Colors.white10
                                              : Colors.black12),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        hourStr,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: i == 0
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: i == 0 ? accent : null,
                                        ),
                                      ),
                                      Text(emoji,
                                          style:
                                              const TextStyle(fontSize: 20)),
                                      Text(
                                        tempStr,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (h.precipitationProbability > 20)
                                        Text(
                                          '${h.precipitationProbability.round()}%',
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0284C7),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Activity Suitability Intelligence Card
                        if (activities.isNotEmpty) ...[
                          ActivityIntelligenceCard(
                            activities: activities,
                            accent: accent,
                          ),
                          const SizedBox(height: 14),
                        ],

                        // What Should I Wear Today Card
                        if (outfits.isNotEmpty) ...[
                          OutfitRecommendationCard(
                            items: outfits,
                            accent: accent,
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Quick Stats Row (AQI, UV, Wind, Rain, Visibility, Dew)
                        QuickStatsRow(
                          weather: weather,
                          airQuality: airQuality,
                          persona: persona,
                        ),
                        const SizedBox(height: 14),

                        // AI Weather Assistant Bar
                        AIAskBar(accent: accent),
                        const SizedBox(height: 22),

                        // Section Divider
                        Row(
                          children: [
                            Text(
                              'PERSONA INTELLIGENCE (${Personas.label(persona).toUpperCase()})',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Divider(
                                color: isDark
                                    ? Colors.white12
                                    : const Color(0xFFE2E8F0),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Persona Specific Dynamic Widget (Preserved)
                        _buildPersonaWidget(
                          persona: persona,
                          weather: weather,
                          airQuality: airQuality,
                          marine: marine,
                          savedCities: savedCities,
                          onCitySelect: (city) {
                            ref
                                .read(locationProvider.notifier)
                                .setLocation(city);
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  icon: Icons.radar_rounded,
                  label: 'Map',
                  isSelected: false,
                  accent: accent,
                  onTap: () => context.push('/map'),
                ),
                _navItem(
                  icon: Icons.insights_rounded,
                  label: 'Insights',
                  isSelected: false,
                  accent: accent,
                  onTap: () => _showInsightsSheet(context, accent, isDark),
                ),
                _navItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Assistant',
                  isSelected: false,
                  accent: accent,
                  onTap: () => context.push('/assistant'),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? accent : Colors.grey,
              size: 22,
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
