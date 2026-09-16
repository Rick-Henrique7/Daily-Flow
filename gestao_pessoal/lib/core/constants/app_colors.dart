import 'package:flutter/material.dart';

/// Paleta de cores do Daily Flow.
///
/// Baseada no design system "Financial App — Dark/Green":
/// - Background quase-preto (#0D0D0D) — nunca puro
/// - Accent único neon green (#00E676) — usado com parcimônia
/// - Borders low-contrast (#1E1E1E) — estrutura via profundidade, não linhas
/// - Sem gradientes entre hues — apenas opacity fades
/// - Sem drop shadows
class AppColors {
  AppColors._();

  // === Tokens base (do design system) ===
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF141414);
  static const Color surface2 = Color(0xFF1C1C1C);

  /// Texto primário / foreground
  static const Color textPrimary = Color(0xFFFFFFFF);
  // textSecondary e textTertiary clareados: os valores antigos (#7A7A7A
  // e #525252) falhavam WCAG AA contra o fundo dark e sumiam nos
  // gradientes coloridos do AnimatedBackground. Os novos (~9:1 e ~6:1
  // de contraste) preservam a hierarquia primary > secondary > tertiary
  // mas ficam legíveis em qualquer wallpaper do app.
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF8A8A8A);

  /// Accent único (neon green) — usar com parcimônia
  static const Color primary = Color(0xFF00E676);
  static const Color primaryMuted = Color(0xFF1A3D2B);
  static const Color accentDim = Color(0xFF00B85A);

  /// Border low-contrast (1px)
  static const Color border = Color(0xFF1E1E1E);

  /// Chart bars
  static const Color chartBar1 = Color(0xFF0D2B1A);
  static const Color chartBar2 = Color(0xFF1A4D2E);

  // === Aliases de compatibilidade com código existente ===
  // (mantidos até refactor completo das telas)
  static const Color surfaceElevated = surface2;
  static const Color glassBorder = border;
  static const Color success = primary;

  /// Primary color era chamado `purpleFluidStart` — agora aponta pra
  /// neon green (single accent).
  static const Color purpleFluidStart = primary;
  static const Color purpleFluidEnd = primary;

  /// `cyanWaterStart` apontava para ciano — agora accent-dim.
  static const Color cyanWaterStart = accentDim;
  static const Color cyanWaterEnd = accentDim;

  /// `pinkIridescentStart` apontava para rosa — agora primary-muted.
  static const Color pinkIridescentStart = primaryMuted;
  static const Color pinkIridescentMid = primaryMuted;
  static const Color pinkIridescentEnd = primaryMuted;

  // === Estados funcionais (sem red/orange — spec) ===
  static const Color warning = Color(0xFFB0B0B0); // muted gray
  static const Color danger = Color(0xFF6E6E6E); // muted gray
  static const Color info = primaryMuted;

  // === Prioridade de tarefas (escala verde→cinza) ===
  static const Color priorityHigh = primary;
  static const Color priorityMedium = accentDim;
  static const Color priorityLow = textSecondary;

  // === Vidro (não usado no novo design, mantido p/ compat) ===
  static const Color glassFill = Color(0x00000000); // transparente
  static const Color glassFillStrong = Color(0x00000000);
  static const Color glassShadow = Color(0x00000000);

  // === Gradientes (apenas opacity fades — spec) ===
  /// Gradiente "primary" — fade de opacity (sem mudar de hue).
  static const LinearGradient purpleFluid = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00B85A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// "cyanWater" — mesmo hue, opacity fade.
  static const LinearGradient cyanWater = LinearGradient(
    colors: [Color(0xFF00B85A), Color(0xFF1A3D2B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// "pinkIridescent" — descontinuado (sem segundo hue no design system).
  /// Mantido como fallback apontando para tons verdes.
  static const LinearGradient pinkIridescent = LinearGradient(
    colors: [Color(0xFF1A3D2B), Color(0xFF0D2B1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === Spacing scale (4px base unit — design system) ===
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;

  // === Border radius scale (design system) ===
  static const double radiusSm = 8;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
}