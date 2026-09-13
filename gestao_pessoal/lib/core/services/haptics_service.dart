import 'package:flutter/services.dart';

/// Wrapper do `HapticFeedback` para feedback tátil consistente.
///
/// Centraliza os tipos de vibração e facilita mockar nos testes.
class HapticsService {
  HapticsService();

  Future<void> light() => HapticFeedback.lightImpact();
  Future<void> medium() => HapticFeedback.mediumImpact();
  Future<void> heavy() => HapticFeedback.heavyImpact();
  Future<void> selection() => HapticFeedback.selectionClick();
}
