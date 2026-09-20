import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/weather_model.dart';
import '../data/models/air_quality_model.dart';
import '../data/models/marine_model.dart';
import '../data/models/location_model.dart';
import '../data/repositories/weather_repository.dart';
import 'location_provider.dart';
import 'persona_provider.dart';

class MausamDataBundle {
  final WeatherModel weather;
  final AirQualityModel airQuality;
  final MarineModel marine;
  final LocationModel location;
  final DateTime cachedAt;
  final bool isOffline;

  const MausamDataBundle({
    required this.weather,
    required this.airQuality,
    required this.marine,
    required this.location,
    required this.cachedAt,
    this.isOffline = false,
  });

  String get updatedAgoString {
    final diff = DateTime.now().difference(cachedAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Map<String, dynamic> toCacheJson() => {
        'weather': weather.toCacheJson(),
        'airQuality': airQuality.toCacheJson(),
        'marine': marine.toCacheJson(),
        'location': location.toJson(),
        'cachedAt': cachedAt.toIso8601String(),
      };

  factory MausamDataBundle.fromCacheJson(Map<String, dynamic> json,
      {bool isOffline = true, LocationModel? locationOverride}) {
    return MausamDataBundle(
      weather:
          WeatherModel.fromCacheJson(json['weather'] as Map<String, dynamic>),
      airQuality: AirQualityModel.fromCacheJson(
          json['airQuality'] as Map<String, dynamic>),
      marine:
          MarineModel.fromCacheJson(json['marine'] as Map<String, dynamic>),
      location: locationOverride ??
          LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'] as String)
          : DateTime.now(),
      isOffline: isOffline,
    );
  }

  factory MausamDataBundle.mock([LocationModel? location]) {
    return MausamDataBundle(
      weather: WeatherModel.mock(),
      airQuality: AirQualityModel.mock(),
      marine: MarineModel.mock(),
      location: location ?? LocationModel.defaultLocation(),
      cachedAt: DateTime.now(),
      isOffline: false,
    );
  }

  MausamDataBundle copyWith({
    WeatherModel? weather,
    AirQualityModel? airQuality,
    MarineModel? marine,
    LocationModel? location,
    DateTime? cachedAt,
    bool? isOffline,
  }) {
    return MausamDataBundle(
      weather: weather ?? this.weather,
      airQuality: airQuality ?? this.airQuality,
      marine: marine ?? this.marine,
      location: location ?? this.location,
      cachedAt: cachedAt ?? this.cachedAt,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return OpenMeteoWeatherRepository();
});

final weatherDataProvider =
    FutureProvider.autoDispose<MausamDataBundle>((ref) async {
  // Keep alive to prevent aggressive re-fetching on tab/screen switch
  final link = ref.keepAlive();

  final locationAsync = ref.watch(locationProvider);
  final repo = ref.watch(weatherRepositoryProvider);
  final storage = ref.watch(storageServiceProvider);

  final location = locationAsync.valueOrNull ?? LocationModel.defaultLocation();

  try {
    final results = await Future.wait([
      repo.getWeather(
        latitude: location.latitude,
        longitude: location.longitude,
        cityName: location.cityName,
      ),
      repo.getAirQuality(
        latitude: location.latitude,
        longitude: location.longitude,
      ),
      repo.getMarine(
        latitude: location.latitude,
        longitude: location.longitude,
      ),
    ]);

    final bundle = MausamDataBundle(
      weather: results[0] as WeatherModel,
      airQuality: results[1] as AirQualityModel,
      marine: results[2] as MarineModel,
      location: location,
      cachedAt: DateTime.now(),
      isOffline: false,
    );

    // Persist full bundle for offline-first resilience
    await storage.saveCachedBundle(bundle.toCacheJson());

    return bundle;
  } catch (_) {
    // Attempt to load previously persisted real data from local cache
    final cachedJson = await storage.loadCachedBundle();
    if (cachedJson != null) {
      try {
        return MausamDataBundle.fromCacheJson(
          cachedJson,
          isOffline: true,
          locationOverride: location,
        );
      } catch (_) {
        // Fallback to mock if cached data is malformed
      }
    }
    return MausamDataBundle.mock(location).copyWith(isOffline: true);
  }
});
