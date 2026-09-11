import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/personas.dart';
import '../models/location_model.dart';

class StorageService {
  static const String _keyPersona = 'mausam_user_persona';
  static const String _keyUserName = 'mausam_user_name';
  static const String _keyLastLocation = 'mausam_last_location';
  static const String _keyOnboardingDone = 'mausam_onboarding_done';
  static const String _keySavedCities = 'mausam_saved_cities';
  static const String _keyDarkMode = 'mausam_dark_mode';

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
          latitude: 51.5074,
          longitude: -0.1278,
          cityName: 'London',
          country: 'UK',
        ),
        const LocationModel(
          latitude: 35.6762,
          longitude: 139.6503,
          cityName: 'Tokyo',
          country: 'Japan',
        ),
        const LocationModel(
          latitude: 40.7128,
          longitude: -74.0060,
          cityName: 'New York',
          country: 'USA',
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
}
