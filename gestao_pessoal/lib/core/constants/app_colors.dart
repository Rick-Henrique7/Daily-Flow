import 'package:flutter/material.dart';

/// Paleta de cores do Daily Flow.
///
/// Define o Dark Mode nativo (paleta padrão) e os gradientes vítreos
/// usados nos componentes Liquid Glass.
class AppColors {
  AppColors._();

  // === Fundos base (Dark Mode profundo) ===
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceElevated = Color(0xFF1C1C24);

  // === Texto ===
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFB0B0B8);
  static const Color textTertiary = Color(0xFF6E6E78);

  // === Acentos (gradientes vítreos) ===
  static const Color purpleFluidStart = Color(0xFF8B5CF6);
  static const Color purpleFluidEnd = Color(0xFFC084FC);

  static const Color cyanWaterStart = Color(0xFF06B6D4);
  static const Color cyanWaterEnd = Color(0xFF34D399);

  static const Color pinkIridescentStart = Color(0xFFF43F5E);
  static const Color pinkIridescentMid = Color(0xFFFB7185);
  static const Color pinkIridescentEnd = Color(0xFF818CF8);

  // === Estados funcionais ===
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF43F5E);
  static const Color info = Color(0xFF06B6D4);

  // === Prioridade de tarefas ===
  static const Color priorityHigh = Color(0xFFF43F5E);
  static const Color priorityMedium = Color(0xFFFBBF24);
  static const Color priorityLow = Color(0xFF06B6D4);

  // === Vidro (Glassmorphism) ===
  static const Color glassFill = Color(0x26FFFFFF); // 15% branco
  static const Color glassFillStrong = Color(0x4DFFFFFF); // 30% branco
  static const Color glassBorder = Color(0x80FFFFFF); // 50% branco
  static const Color glassShadow = Color(0x1F000000); // 12% preto

  // === Gradientes pré-montados ===
  static const LinearGradient purpleFluid = LinearGradient(
    colors: [purpleFluidStart, purpleFluidEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanWater = LinearGradient(
    colors: [cyanWaterStart, cyanWaterEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkIridescent = LinearGradient(
    colors: [pinkIridescentStart, pinkIridescentMid, pinkIridescentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
