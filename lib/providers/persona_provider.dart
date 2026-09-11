import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/personas.dart';
import '../data/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class PersonaNotifier extends StateNotifier<String> {
  final StorageService _storage;

  PersonaNotifier(this._storage) : super(Personas.health) {
    _init();
  }

  Future<void> _init() async {
    final saved = await _storage.loadPersona();
    state = saved;
  }

  Future<void> setPersona(String persona) async {
    state = persona;
    await _storage.savePersona(persona);
  }
}

final personaProvider = StateNotifierProvider<PersonaNotifier, String>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PersonaNotifier(storage);
});

class UserNameNotifier extends StateNotifier<String> {
  final StorageService _storage;

  UserNameNotifier(this._storage) : super('Friend') {
    _init();
  }

  Future<void> _init() async {
    final name = await _storage.loadUserName();
    state = name;
  }

  Future<void> setUserName(String name) async {
    state = name;
    await _storage.saveUserName(name);
  }
}

final userNameProvider = StateNotifierProvider<UserNameNotifier, String>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return UserNameNotifier(storage);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storage;

  ThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _init();
  }

  Future<void> _init() async {
    final isDark = await _storage.loadDarkMode();
    if (isDark != null) {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    await _storage.saveDarkMode(next == ThemeMode.dark);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeModeNotifier(storage);
});
