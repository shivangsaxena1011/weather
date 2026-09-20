import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/personas.dart';
import '../../data/models/location_model.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/air_quality_model.dart';
import '../../engines/comfort_score_engine.dart';
import '../../providers/location_provider.dart';
import '../../providers/persona_provider.dart';
import '../../providers/weather_provider.dart';
import '../../core/utils/unit_converter.dart';
import '../../providers/unit_provider.dart';
import '../../widgets/common/weather_card.dart';

class LocationsScreen extends ConsumerStatefulWidget {
  const LocationsScreen({super.key});

  @override
  ConsumerState<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _selectedForComparison = {};
  final Map<String, (WeatherModel, AirQualityModel)?> _comparisonData = {};
  bool _loadingComparison = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getTagEmoji(String tag) {
    switch (tag.toLowerCase()) {
      case 'home':
        return '🏠';
      case 'college':
        return '🎓';
      case 'work':
        return '💼';
      default:
        return '📍';
    }
  }

  void _showAddPlaceDialog() {
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
                  const Text(
                    'Add a Saved Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search city (e.g. Bhopal, Goa, London)...',
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
                            leading: const Icon(Icons.location_on_rounded),
                            title: Text(loc.cityName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text('${loc.state ?? ''} ${loc.country}'),
                            onTap: () {
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

  void _showEditPlaceDialog(LocationModel loc) {
    final nameController = TextEditingController(text: loc.displayName);
    String selectedTag = loc.tag;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Location'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Label / Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Tag Type:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['home', 'college', 'work', 'custom'].map((tag) {
                    final isSelected = selectedTag == tag;
                    return ChoiceChip(
                      label: Text('${_getTagEmoji(tag)} ${tag.toUpperCase()}'),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => selectedTag = tag);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref
                      .read(savedCitiesProvider.notifier)
                      .removeCity(loc.cityName);
                  Navigator.pop(ctx);
                },
                child: const Text('Delete',
                    style: TextStyle(color: Colors.redAccent)),
              ),
              ElevatedButton(
                onPressed: () {
                  final newName = nameController.text.trim();
                  if (newName.isNotEmpty) {
                    ref
                        .read(savedCitiesProvider.notifier)
                        .renameCity(loc.cityName, newName);
                  }
                  ref
                      .read(savedCitiesProvider.notifier)
                      .setTag(loc.cityName, selectedTag);
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _fetchComparisonData(List<LocationModel> cities) async {
    setState(() => _loadingComparison = true);
    final repo = ref.read(weatherRepositoryProvider);

    for (final loc in cities) {
      if (_selectedForComparison.contains(loc.cityName)) {
        try {
          final weather = await repo.getWeather(
            latitude: loc.latitude,
            longitude: loc.longitude,
            cityName: loc.cityName,
          );
          final aqi = await repo.getAirQuality(
            latitude: loc.latitude,
            longitude: loc.longitude,
          );
          _comparisonData[loc.cityName] = (weather, aqi);
        } catch (_) {}
      }
    }
    setState(() => _loadingComparison = false);
  }

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final accent = Personas.color(persona);
    final savedPlaces = ref.watch(savedCitiesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations & Comparison',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accent,
          labelColor: accent,
          tabs: const [
            Tab(icon: Icon(Icons.bookmark_rounded), text: 'My Places'),
            Tab(icon: Icon(Icons.compare_arrows_rounded), text: 'Compare'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: My Places
          _buildMyPlacesTab(savedPlaces, accent, isDark),

          // TAB 2: Compare Locations
          _buildCompareTab(savedPlaces, accent, isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPlaceDialog,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add Place'),
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildMyPlacesTab(
      List<LocationModel> savedPlaces, Color accent, bool isDark) {
    if (savedPlaces.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No saved places yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('Tap "Add Place" to bookmark your favorite cities.'),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: savedPlaces.length,
      onReorder: (oldIdx, newIdx) {
        ref.read(savedCitiesProvider.notifier).reorder(oldIdx, newIdx);
      },
      itemBuilder: (context, i) {
        final loc = savedPlaces[i];
        final emoji = _getTagEmoji(loc.tag);

        return Container(
          key: ValueKey(loc.cityName),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2430) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: loc.isFavorite
                  ? accent.withOpacity(0.5)
                  : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              width: loc.isFavorite ? 1.5 : 1,
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: accent.withOpacity(0.15),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            title: Row(
              children: [
                Text(
                  loc.displayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                if (loc.isFavorite) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.star_rounded, size: 18, color: accent),
                ],
              ],
            ),
            subtitle: Text(
              loc.country.isNotEmpty
                  ? '${loc.cityName}, ${loc.country}'
                  : loc.cityName,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    loc.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: loc.isFavorite ? accent : Colors.grey,
                  ),
                  onPressed: () {
                    ref
                        .read(savedCitiesProvider.notifier)
                        .toggleFavorite(loc.cityName);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () => _showEditPlaceDialog(loc),
                ),
                const Icon(Icons.drag_handle_rounded, color: Colors.grey),
              ],
            ),
            onTap: () {
              // Set as active location and return to home
              ref.read(locationProvider.notifier).setLocation(loc);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Widget _buildCompareTab(
      List<LocationModel> savedPlaces, Color accent, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select up to 3 places to compare:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: savedPlaces.map((loc) {
              final isSelected = _selectedForComparison.contains(loc.cityName);
              return FilterChip(
                selected: isSelected,
                label: Text('${_getTagEmoji(loc.tag)} ${loc.displayName}'),
                selectedColor: accent.withOpacity(0.2),
                checkmarkColor: accent,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      if (_selectedForComparison.length < 3) {
                        _selectedForComparison.add(loc.cityName);
                        _fetchComparisonData(savedPlaces);
                      }
                    } else {
                      _selectedForComparison.remove(loc.cityName);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (_loadingComparison)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_selectedForComparison.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.compare_arrows_rounded,
                      size: 48, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 10),
                  const Text('Select at least two cities above to compare weather parameters side-by-side.'),
                ],
              ),
            )
          else
            _buildComparisonMatrix(accent, isDark),
        ],
      ),
    );
  }

  Widget _buildComparisonMatrix(Color accent, bool isDark) {
    final cities = _selectedForComparison.toList();
    final unitSettings = ref.watch(unitSettingsProvider);

    return WeatherCard(
      title: 'SIDE-BY-SIDE WEATHER COMPARISON',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          columns: [
            const DataColumn(label: Text('Metric', style: TextStyle(fontWeight: FontWeight.bold))),
            ...cities.map((city) => DataColumn(
                  label: Text(city, style: TextStyle(fontWeight: FontWeight.bold, color: accent)),
                )),
          ],
          rows: [
            _buildRow('Temperature', cities, (data) => UnitConverter.formatTemp(data.$1.currentTemp, unitSettings.tempUnit)),
            _buildRow('Feels Like', cities, (data) => UnitConverter.formatTemp(data.$1.feelsLike, unitSettings.tempUnit)),
            _buildRow('Rain Risk', cities, (data) => '${data.$1.precipitationProbability.round()}%'),
            _buildRow('Air Quality', cities, (data) => '${data.$2.aqi} AQI'),
            _buildRow('UV Index', cities, (data) => data.$1.uvIndex.toStringAsFixed(1)),
            _buildRow('Wind Speed', cities, (data) => UnitConverter.formatWind(data.$1.windSpeed, unitSettings.windUnit)),
            _buildRow('Comfort Score', cities, (data) {
              final score = ComfortScoreEngine.calculate(weather: data.$1, airQuality: data.$2);
              return '${score.overallScore}/100';
            }),
          ],
        ),
      ),
    );
  }

  DataRow _buildRow(
      String metric,
      List<String> cities,
      String Function((WeatherModel, AirQualityModel)) formatter,
      ) {
    return DataRow(
      cells: [
        DataCell(Text(metric, style: const TextStyle(fontWeight: FontWeight.w600))),
        ...cities.map((city) {
          final data = _comparisonData[city];
          return DataCell(
            Text(data != null ? formatter(data) : '...'),
          );
        }),
      ],
    );
  }
}
