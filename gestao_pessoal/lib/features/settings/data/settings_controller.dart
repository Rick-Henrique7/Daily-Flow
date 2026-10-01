import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/constants/app_colors.dart';
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

  /// Troca o estilo visual. Ao trocar, a cor de destaque volta para o
  /// padrão do novo estilo (coral no editorial, lilás no glass) — uma
  /// cor escolhida para fundo escuro raramente funciona no creme.
  Future<void> updateStyle(AppStyle style) async {
    if (style == state.style) return;
    var next = state.copyWith(
      style: style,
      accentColor: style.defaultAccentHex,
    );
    if (style.isGlass && next.blobIntensity < 0.1) {
      next = next.copyWith(
        blobIntensity: AppSettings.defaults.blobIntensity,
        wallpaperMode: WallpaperMode.animated,
      );
    }
    state = next;
    await _persist();
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

  /// Restaura a cor de destaque para o padrão do estilo atual.
  Future<void> resetAccentColor() async {
    state = state.copyWith(accentColor: state.style.defaultAccentHex);
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
    // Mantém o estilo escolhido; restaura o resto.
    final style = state.style;
    state = AppSettings.defaults.copyWith(
      style: style,
      accentColor: style.defaultAccentHex,
    );
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

/// Provider que resolve a cor de texto (foreground) configurada pelo
/// usuário como `Color`. Widgets customizados que pintam texto
/// específico (não via `Theme.of(context).textTheme`) consomem
/// daqui para reagir à personalização.
///
/// Hierarquia recomendada ao usar:
/// - foreground puro para texto primário (títulos, contadores)
/// - foreground com `Color.withValues(alpha: 0.7)` para texto
///   secundário (subtítulos, labels) — preserva hierarquia visual
///   mantendo coerência com a cor escolhida.
final textColorProvider = Provider<Color>((ref) {
  final settings = ref.watch(settingsProvider);
  // No editorial o texto é sempre tinta grafite (contraste no creme).
  if (!settings.style.isGlass) return AppPalette.editorial.textPrimary;
  final hex = settings.textColor;
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
});
