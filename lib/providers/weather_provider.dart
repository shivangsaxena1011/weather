import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/weather_model.dart';
import '../data/models/air_quality_model.dart';
import '../data/models/marine_model.dart';
import '../data/models/location_model.dart';
import '../data/repositories/weather_repository.dart';
import 'location_provider.dart';

class MausamDataBundle {
  final WeatherModel weather;
  final AirQualityModel airQuality;
  final MarineModel marine;
  final LocationModel location;

  const MausamDataBundle({
    required this.weather,
    required this.airQuality,
    required this.marine,
    required this.location,
  });

  factory MausamDataBundle.mock([LocationModel? location]) {
    return MausamDataBundle(
      weather: WeatherModel.mock(),
      airQuality: AirQualityModel.mock(),
      marine: MarineModel.mock(),
      location: location ?? LocationModel.defaultLocation(),
    );
  }
}

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository();
});

final weatherDataProvider =
    FutureProvider.autoDispose<MausamDataBundle>((ref) async {
  // Keep alive to prevent aggressive re-fetching on tab/screen switch
  final link = ref.keepAlive();

  final locationAsync = ref.watch(locationProvider);
  final repo = ref.watch(weatherRepositoryProvider);

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

    return MausamDataBundle(
      weather: results[0] as WeatherModel,
      airQuality: results[1] as AirQualityModel,
      marine: results[2] as MarineModel,
      location: location,
    );
  } catch (_) {
    return MausamDataBundle.mock(location);
  }
});
