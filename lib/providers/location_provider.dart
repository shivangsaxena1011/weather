import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models/location_model.dart';
import '../data/services/geocoding_service.dart';
import 'persona_provider.dart';

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

class LocationNotifier extends StateNotifier<AsyncValue<LocationModel>> {
  final GeocodingService _geocoding;
  final Ref _ref;

  LocationNotifier(this._geocoding, this._ref)
      : super(const AsyncValue.loading()) {
    fetchCurrentLocation();
  }

  Future<void> fetchCurrentLocation() async {
    state = const AsyncValue.loading();
    try {
      final storage = _ref.read(storageServiceProvider);
      final lastLoc = await storage.loadLastLocation();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = AsyncValue.data(lastLoc ?? LocationModel.defaultLocation());
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = AsyncValue.data(lastLoc ?? LocationModel.defaultLocation());
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = AsyncValue.data(lastLoc ?? LocationModel.defaultLocation());
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      final location = await _geocoding.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      await storage.saveLastLocation(location);
      state = AsyncValue.data(location);
    } catch (_) {
      final storage = _ref.read(storageServiceProvider);
      final lastLoc = await storage.loadLastLocation();
      state = AsyncValue.data(lastLoc ?? LocationModel.defaultLocation());
    }
  }

  Future<void> setLocation(LocationModel location) async {
    state = AsyncValue.data(location);
    final storage = _ref.read(storageServiceProvider);
    await storage.saveLastLocation(location);
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<LocationModel>>((ref) {
  final geocoding = ref.watch(geocodingServiceProvider);
  return LocationNotifier(geocoding, ref);
});

class SavedCitiesNotifier extends StateNotifier<List<LocationModel>> {
  final Ref _ref;

  SavedCitiesNotifier(this._ref) : super([]) {
    _init();
  }

  Future<void> _init() async {
    final storage = _ref.read(storageServiceProvider);
    final list = await storage.loadSavedCities();
    state = list;
  }

  Future<void> addCity(LocationModel city) async {
    if (!state.any((c) => c.cityName == city.cityName)) {
      final updated = [...state, city];
      state = updated;
      final storage = _ref.read(storageServiceProvider);
      await storage.saveSavedCities(updated);
    }
  }

  Future<void> removeCity(String cityName) async {
    final updated = state.where((c) => c.cityName != cityName).toList();
    state = updated;
    final storage = _ref.read(storageServiceProvider);
    await storage.saveSavedCities(updated);
  }

  Future<void> renameCity(String cityName, String newName) async {
    final updated = state.map((c) {
      if (c.cityName == cityName) {
        return c.copyWith(customName: newName);
      }
      return c;
    }).toList();
    state = updated;
    final storage = _ref.read(storageServiceProvider);
    await storage.saveSavedCities(updated);
  }

  Future<void> setTag(String cityName, String tag) async {
    final updated = state.map((c) {
      if (c.cityName == cityName) {
        return c.copyWith(tag: tag);
      }
      return c;
    }).toList();
    state = updated;
    final storage = _ref.read(storageServiceProvider);
    await storage.saveSavedCities(updated);
  }

  Future<void> toggleFavorite(String cityName) async {
    final updated = state.map((c) {
      if (c.cityName == cityName) {
        return c.copyWith(isFavorite: !c.isFavorite);
      }
      return c;
    }).toList();
    state = updated;
    final storage = _ref.read(storageServiceProvider);
    await storage.saveSavedCities(updated);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final items = List<LocationModel>.from(state);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = items;
    final storage = _ref.read(storageServiceProvider);
    await storage.saveSavedCities(items);
  }
}

final savedCitiesProvider =
    StateNotifierProvider<SavedCitiesNotifier, List<LocationModel>>((ref) {
  return SavedCitiesNotifier(ref);
});
