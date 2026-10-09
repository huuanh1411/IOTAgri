// lib/providers/settings_provider.dart
// Phase 7: Settings provider for units, language, persisted with SharedPreferences.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TemperatureUnit { celsius, fahrenheit }
enum VolumeUnit { ml, oz }

data class Settings {
  final TemperatureUnit temperatureUnit;
  final VolumeUnit volumeUnit;
  final String language; // 'vi' or 'en'

  const Settings({
    required this.temperatureUnit,
    required this.volumeUnit,
    required this.language,
  });

  Settings copyWith({
    TemperatureUnit? temperatureUnit,
    VolumeUnit? volumeUnit,
    String? language,
  }) {
    return Settings(
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      language: language ?? this.language,
    );
  }
}

/// StateNotifier that loads/saves the settings via SharedPreferences.
class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(const Settings(temperatureUnit: TemperatureUnit.celsius, volumeUnit: VolumeUnit.ml, language: 'vi')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final temp = prefs.getString('tempUnit') ?? 'c';
    final vol = prefs.getString('volUnit') ?? 'ml';
    final lang = prefs.getString('language') ?? 'vi';
    state = Settings(
      temperatureUnit: temp == 'c' ? TemperatureUnit.celsius : TemperatureUnit.fahrenheit,
      volumeUnit: vol == 'ml' ? VolumeUnit.ml : VolumeUnit.oz,
      language: lang,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tempUnit', state.temperatureUnit == TemperatureUnit.celsius ? 'c' : 'f');
    await prefs.setString('volUnit', state.volumeUnit == VolumeUnit.ml ? 'ml' : 'oz');
    await prefs.setString('language', state.language);
  }

  void setTemperatureUnit(TemperatureUnit unit) {
    state = state.copyWith(temperatureUnit: unit);
    _save();
  }

  void setVolumeUnit(VolumeUnit unit) {
    state = state.copyWith(volumeUnit: unit);
    _save();
  }

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
    _save();
  }
}

/// Provider exposing the SettingsNotifier.
final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) => SettingsNotifier());
