import 'package:flutter/services.dart';

/// Wrapper do `HapticFeedback` para feedback tátil consistente.
///
/// Centraliza os tipos de vibração e facilita mockar nos testes.
/// Quando [enabled] é `false`, **todas as chamadas são no-op** — útil
/// para usuários que preferem não sentir vibração.
class HapticsService {
  HapticsService({this.enabled = true});

  /// Se `false`, nenhum método dispara vibração real.
  final bool enabled;

  Future<void> light() async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> medium() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavy() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> selection() async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }
}