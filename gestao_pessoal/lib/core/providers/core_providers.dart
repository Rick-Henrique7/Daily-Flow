import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/prefs_store.dart';
import '../services/haptics_service.dart';
import '../services/sound_service.dart';

/// Providers de infraestrutura compartilhados por todas as features.
///
/// Ficam em `core/` (e não dentro de uma feature) para que nenhuma
/// feature precise importar outra só para acessar armazenamento ou
/// serviços de plataforma. Ver `docs/adr/0002-providers-em-core.md`.

/// Armazenamento local. Não tem implementação padrão: o `main.dart`
/// (composition root) injeta a instância já aberta via override.
final prefsStoreProvider = Provider<PrefsStore>((ref) {
  throw UnimplementedError(
    'prefsStoreProvider precisa ser sobrescrito no main() com PrefsStore.open().',
  );
});

/// Preferências de feedback (vibração e som) consumidas pelos serviços.
///
/// `core/` não conhece a feature de configurações. Em vez de importá-la
/// (o que criaria dependência circular), o core declara esta "porta" e
/// o `main.dart` a liga às configurações do usuário com um override —
/// inversão de dependência (o "D" do SOLID).
class FeedbackPreferences {
  const FeedbackPreferences({this.haptics = true, this.sound = true});

  final bool haptics;
  final bool sound;
}

final feedbackPreferencesProvider = Provider<FeedbackPreferences>(
  (ref) => const FeedbackPreferences(),
);

/// Vibração. Vira no-op quando o usuário desliga em Configurações.
final hapticsServiceProvider = Provider<HapticsService>((ref) {
  return HapticsService(enabled: ref.watch(feedbackPreferencesProvider).haptics);
});

/// Som de conclusão. O player é liberado quando o provider é recriado
/// (antes, cada mudança nas configurações vazava um `AudioPlayer`).
final soundServiceProvider = Provider<SoundService>((ref) {
  final service =
      SoundService(enabled: ref.watch(feedbackPreferencesProvider).sound);
  ref.onDispose(service.dispose);
  return service;
});

/// Data de hoje (sem hora), recalculada automaticamente à meia-noite.
///
/// Todas as regras que dependem de "hoje" leem daqui. Isso dá uma chave
/// estável para os providers (antes `DateTime.now()` com segundos virava
/// chave nova a cada build) e permite fixar a data nos testes.
final todayProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final timer = Timer(tomorrow.difference(now), ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return DateTime(now.year, now.month, now.day);
});
