import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/unit_converter.dart';
import '../data/services/storage_service.dart';
import 'persona_provider.dart';

class UnitSettingsNotifier extends StateNotifier<UnitSettings> {
  final StorageService _storage;

  UnitSettingsNotifier(this._storage) : super(const UnitSettings()) {
    _init();
  }

  Future<void> _init() async {
    final saved = await _storage.loadUnitSettings();
    state = saved;
  }

  Future<void> setTempUnit(TemperatureUnit unit) async {
    final updated = state.copyWith(tempUnit: unit);
    state = updated;
    await _storage.saveUnitSettings(updated);
  }

  Future<void> setWindUnit(WindSpeedUnit unit) async {
    final updated = state.copyWith(windUnit: unit);
    state = updated;
    await _storage.saveUnitSettings(updated);
  }

  Future<void> setPressureUnit(PressureUnit unit) async {
    final updated = state.copyWith(pressureUnit: unit);
    state = updated;
    await _storage.saveUnitSettings(updated);
  }
}

final unitSettingsProvider =
    StateNotifierProvider<UnitSettingsNotifier, UnitSettings>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return UnitSettingsNotifier(storage);
});
