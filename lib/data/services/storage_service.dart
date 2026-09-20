import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/personas.dart';
import '../../core/utils/unit_converter.dart';
import '../models/location_model.dart';

class StorageService {
  static const String _keyPersona = 'mausam_user_persona';
  static const String _keyUserName = 'mausam_user_name';
  static const String _keyLastLocation = 'mausam_last_location';
  static const String _keyOnboardingDone = 'mausam_onboarding_done';
  static const String _keySavedCities = 'mausam_saved_cities';
  static const String _keyDarkMode = 'mausam_dark_mode';
  static const String _keyCachedBundle = 'mausam_cached_bundle';
  static const String _keyUnitSettings = 'mausam_unit_settings';
  static const String _keyAlertPrefs = 'mausam_alert_preferences';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> savePersona(String personaId) async {
    final prefs = await _prefs;
    await prefs.setString(_keyPersona, personaId);
  }

  Future<String> loadPersona() async {
    final prefs = await _prefs;
    return prefs.getString(_keyPersona) ?? Personas.health;
  }

  Future<void> saveUserName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUserName, name);
  }

  Future<String> loadUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserName) ?? 'Friend';
  }

  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await _prefs;
    await prefs.setString(_keyLastLocation, jsonEncode(location.toJson()));
  }

  Future<LocationModel?> loadLastLocation() async {
    final prefs = await _prefs;
    final str = prefs.getString(_keyLastLocation);
    if (str == null) return null;
    try {
      return LocationModel.fromJson(jsonDecode(str) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await _prefs;
    await prefs.setBool(_keyOnboardingDone, true);
  }

  Future<void> saveSavedCities(List<LocationModel> cities) async {
    final prefs = await _prefs;
    final list = cities.map((c) => c.toJson()).toList();
    await prefs.setString(_keySavedCities, jsonEncode(list));
  }

  Future<List<LocationModel>> loadSavedCities() async {
    final prefs = await _prefs;
    final str = prefs.getString(_keySavedCities);
    if (str == null) {
      return [
        const LocationModel(
          latitude: 19.0760,
          longitude: 72.8777,
          cityName: 'Mumbai',
          country: 'India',
          state: 'Maharashtra',
          tag: 'home',
          isFavorite: true,
        ),
        const LocationModel(
          latitude: 28.6139,
          longitude: 77.2090,
          cityName: 'Delhi',
          country: 'India',
          state: 'Delhi',
          tag: 'college',
        ),
        const LocationModel(
          latitude: 12.9716,
          longitude: 77.5946,
          cityName: 'Bengaluru',
          country: 'India',
          state: 'Karnataka',
          tag: 'work',
        ),
        const LocationModel(
          latitude: 51.5074,
          longitude: -0.1278,
          cityName: 'London',
          country: 'UK',
          tag: 'custom',
        ),
        const LocationModel(
          latitude: 35.6762,
          longitude: 139.6503,
          cityName: 'Tokyo',
          country: 'Japan',
          tag: 'custom',
        ),
      ];
    }
    try {
      final list = jsonDecode(str) as List<dynamic>;
      return list
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool?> loadDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyDarkMode);
  }

  Future<void> saveDarkMode(bool isDark) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyDarkMode, isDark);
  }

  // --- Offline Weather Bundle Cache ---
  Future<void> saveCachedBundle(Map<String, dynamic> bundleJson) async {
    final prefs = await _prefs;
    await prefs.setString(_keyCachedBundle, jsonEncode(bundleJson));
  }

  Future<Map<String, dynamic>?> loadCachedBundle() async {
    final prefs = await _prefs;
    final str = prefs.getString(_keyCachedBundle);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // --- Unit Preferences ---
  Future<void> saveUnitSettings(UnitSettings settings) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUnitSettings, jsonEncode(settings.toJson()));
  }

  Future<UnitSettings> loadUnitSettings() async {
    final prefs = await _prefs;
    final str = prefs.getString(_keyUnitSettings);
    if (str == null) return const UnitSettings();
    try {
      return UnitSettings.fromJson(jsonDecode(str) as Map<String, dynamic>);
    } catch (_) {
      return const UnitSettings();
    }
  }

  // --- Alert Notification Preferences ---
  Future<void> saveAlertPreferences(Map<String, bool> prefsMap) async {
    final prefs = await _prefs;
    await prefs.setString(_keyAlertPrefs, jsonEncode(prefsMap));
  }

  Future<Map<String, bool>> loadAlertPreferences() async {
    final prefs = await _prefs;
    final str = prefs.getString(_keyAlertPrefs);
    if (str == null) {
      return {
        'rain': true,
        'heavyRain': true,
        'storm': true,
        'extremeHeat': true,
        'extremeCold': true,
        'uv': true,
        'aqi': true,
        'wind': false,
        'fog': true,
      };
    }
    try {
      final map = jsonDecode(str) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v as bool));
    } catch (_) {
      return {
        'rain': true,
        'heavyRain': true,
        'storm': true,
        'extremeHeat': true,
        'extremeCold': true,
        'uv': true,
        'aqi': true,
        'wind': false,
        'fog': true,
      };
    }
  }

  Future<void> clearCache() async {
    final prefs = await _prefs;
    await prefs.remove(_keyCachedBundle);
  }
}
