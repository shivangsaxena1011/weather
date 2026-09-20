import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/personas.dart';
import '../../data/models/location_model.dart';
import '../../data/models/weather_model.dart';
import '../../providers/location_provider.dart';
import '../../providers/persona_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/common/weather_card.dart';

class TravelScreen extends ConsumerStatefulWidget {
  const TravelScreen({super.key});

  @override
  ConsumerState<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends ConsumerState<TravelScreen> {
  final TextEditingController _destinationController = TextEditingController();
  LocationModel? _selectedDestination;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 5));

  WeatherModel? _travelWeather;
  bool _loading = false;
  List<LocationModel> _searchResults = [];
  bool _searchingCity = false;

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _searchDestination(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _searchingCity = true);
    final geocoding = ref.read(geocodingServiceProvider);
    final results = await geocoding.searchCity(query);
    setState(() {
      _searchResults = results;
      _searchingCity = false;
    });
  }

  Future<void> _fetchTravelForecast(LocationModel loc) async {
    setState(() {
      _selectedDestination = loc;
      _searchResults.clear();
      _destinationController.text = loc.cityName;
      _loading = true;
    });

    final repo = ref.read(weatherRepositoryProvider);
    try {
      final weather = await repo.getWeather(
        latitude: loc.latitude,
        longitude: loc.longitude,
        cityName: loc.cityName,
      );
      setState(() {
        _travelWeather = weather;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<String> _generatePackingChecklist(WeatherModel weather) {
    final checklist = <String>[];
    final minTemp = weather.daily.isNotEmpty
        ? weather.daily.map((d) => d.tempMin).reduce((a, b) => a < b ? a : b)
        : weather.currentTemp - 4;
    final maxTemp = weather.daily.isNotEmpty
        ? weather.daily.map((d) => d.tempMax).reduce((a, b) => a > b ? a : b)
        : weather.currentTemp + 5;
    final maxRainProb = weather.daily.isNotEmpty
        ? weather.daily
            .map((d) => d.precipitationProbabilityMax)
            .reduce((a, b) => a > b ? a : b)
        : weather.precipitationProbability;
    final maxUv = weather.daily.isNotEmpty
        ? weather.daily.map((d) => d.uvIndexMax).reduce((a, b) => a > b ? a : b)
        : weather.uvIndex;

    // Thermal packing
    if (minTemp <= 8) {
      checklist.addAll(['🧥 Thermal insulated coat', '🧣 Warm woolen scarf', '🧤 Gloves']);
    } else if (minTemp <= 16) {
      checklist.addAll(['🧥 Light jacket / cardigan', '👖 Long denim / trousers']);
    }

    if (maxTemp >= 28) {
      checklist.addAll(['👕 Light breathable cotton tops', '🩳 Chinos / shorts', '💧 Reusable water flask']);
    }

    // Rain protection
    if (maxRainProb >= 35) {
      checklist.addAll(['☂️ Compact folding umbrella', '🥾 Waterproof shoes / boots', '🎒 Rain cover for daypack']);
    }

    // Solar protection
    if (maxUv >= 6.0) {
      checklist.addAll(['🧴 SPF 50+ Sunscreen', '🕶️ UV-protective sunglasses', '🧢 Travel sun cap']);
    }

    // Universal essentials
    checklist.addAll(['🔌 Universal travel adapter', '🔋 High-capacity power bank', '💊 Personal travel meds']);

    return checklist.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final persona = ref.watch(personaProvider);
    final accent = Personas.color(persona);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Weather Planner',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Search Card
            WeatherCard(
              title: 'TRIP DESTINATION & DATES',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      hintText: 'Enter destination (e.g. Goa, Manali, Tokyo)...',
                      prefixIcon: const Icon(Icons.flight_takeoff_rounded),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search_rounded),
                        onPressed: () =>
                            _searchDestination(_destinationController.text),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF141923)
                          : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _searchDestination,
                  ),

                  if (_searchingCity)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF141923) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final res = _searchResults[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.pin_drop_rounded),
                            title: Text(res.cityName,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(res.country),
                            onTap: () => _fetchTravelForecast(res),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 14),

                  // Dates Selector Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_rounded, size: 16),
                          label: Text(
                              'Depart: ${DateFormat('MMM dd').format(_startDate)}'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 90)),
                            );
                            if (picked != null) {
                              setState(() => _startDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.event_available_rounded, size: 16),
                          label: Text(
                              'Return: ${DateFormat('MMM dd').format(_endDate)}'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate,
                              firstDate: _startDate,
                              lastDate:
                                  DateTime.now().add(const Duration(days: 90)),
                            );
                            if (picked != null) {
                              setState(() => _endDate = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_travelWeather != null && _selectedDestination != null) ...[
              // Travel Forecast Overview
              WeatherCard(
                title: 'DESTINATION OUTLOOK: ${_selectedDestination!.cityName.toUpperCase()}',
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_travelWeather!.currentTemp.round()}°C',
                              style: const TextStyle(
                                  fontSize: 38, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Feels like ${_travelWeather!.feelsLike.round()}°C',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${_travelWeather!.precipitationProbability.round()}%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                              const Text('Rain Risk',
                                  style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _tripStat('Wind', '${_travelWeather!.windSpeed.round()} km/h'),
                        _tripStat('UV Max', _travelWeather!.uvIndex.toStringAsFixed(1)),
                        _tripStat('Humidity', '${_travelWeather!.humidity.round()}%'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // AI Packing Checklist
              WeatherCard(
                title: 'SMART PACKING CHECKLIST',
                titleTrailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AI Recommended',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
                child: Column(
                  children: _generatePackingChecklist(_travelWeather!).map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              size: 18, color: Color(0xFF10B981)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ] else ...[
              // Placeholder guide
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.flight_takeoff_rounded,
                        size: 56, color: Colors.grey.withOpacity(0.4)),
                    const SizedBox(height: 14),
                    const Text(
                      'Plan Weather for Your Next Trip',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Search any global city above to generate high-precision travel forecasts and context-aware packing checklists.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tripStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
