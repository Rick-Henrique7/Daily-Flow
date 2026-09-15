import 'package:audioplayers/audioplayers.dart';

/// Wrapper para tocar sons curtos (efeitos de UI).
///
/// Usado para feedback sonoro de conclusão (success.mp3). O player é
/// cacheado e reutilizado entre chamadas para evitar custo de criar
/// um novo `AudioPlayer` a cada play.
///
/// Se [enabled] for `false`, `playSuccess()` é no-op.
class SoundService {
  SoundService({this.enabled = true});

  /// Se `false`, nenhum som é tocado.
  final bool enabled;

  final AudioPlayer _player = AudioPlayer();

  Future<void> playSuccess() async {
    if (!enabled) return;
    try {
      // `AssetSource('sounds/success.mp3')` carrega do bundle
      // declarado em pubspec.yaml (assets/sounds/success.mp3).
      await _player.stop();
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (_) {
      // Silencioso em caso de erro — não queremos crashar por áudio
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}