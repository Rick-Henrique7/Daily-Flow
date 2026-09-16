import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../habits/data/habits_controller.dart';
import '../domain/app_settings.dart';

/// Notifier que mantém as configurações do app em memória e persiste
/// cada mudança em [PrefsKeys.settings].
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final store = ref.watch(prefsStoreProvider);
    return AppSettings.fromJsonString(store.settings);
  }

  Future<void> _persist() async {
    final store = ref.read(prefsStoreProvider);
    await store.setSettings(state.toJsonString());
  }

  Future<void> updateWallpaperSeed(String hex) async {
    state = state.copyWith(wallpaperSeed: hex);
    await _persist();
  }

  Future<void> updateWallpaperSolidColor(String hex) async {
    state = state.copyWith(wallpaperSolidColor: hex);
    await _persist();
  }

  Future<void> updateWallpaperMode(WallpaperMode mode) async {
    state = state.copyWith(wallpaperMode: mode);
    await _persist();
  }

  Future<void> updateBlobIntensity(double intensity) async {
    state = state.copyWith(blobIntensity: intensity);
    await _persist();
  }

  Future<void> updateSaturation(double saturation) async {
    state = state.copyWith(wallpaperSaturation: saturation);
    await _persist();
  }

  Future<void> updateHapticsEnabled(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    await _persist();
  }

  Future<void> updateSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _persist();
  }

  Future<void> updateTextColor(String hex) async {
    state = state.copyWith(textColor: hex);
    await _persist();
  }

  /// Restaura a cor do texto para o default (`#FFFFFF`).
  Future<void> resetTextColor() async {
    state = state.copyWith(textColor: AppSettings.defaults.textColor);
    await _persist();
  }

  Future<void> updateAccentColor(String hex) async {
    state = state.copyWith(accentColor: hex);
    await _persist();
  }

  /// Restaura a cor de destaque para o default (`#00E676` neon green).
  Future<void> resetAccentColor() async {
    state = state.copyWith(accentColor: AppSettings.defaults.accentColor);
    await _persist();
  }

  Future<void> updatePomodoroFocusColor(String hex) async {
    state = state.copyWith(pomodoroFocusColor: hex);
    await _persist();
  }

  Future<void> updatePomodoroShortBreakColor(String hex) async {
    state = state.copyWith(pomodoroShortBreakColor: hex);
    await _persist();
  }

  Future<void> updatePomodoroLongBreakColor(String hex) async {
    state = state.copyWith(pomodoroLongBreakColor: hex);
    await _persist();
  }

  Future<void> resetDefaults() async {
    state = AppSettings.defaults;
    await _persist();
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// Provider que resolve a cor de destaque (accent) configurada pelo
/// usuário como `Color`. Widgets que precisam pintar elementos
/// "ativos" (priority bar, check button, etc.) consomem via
/// `ref.watch(accentColorProvider)`.
final accentColorProvider = Provider<Color>((ref) {
  final hex = ref.watch(settingsProvider).accentColor;
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
});
