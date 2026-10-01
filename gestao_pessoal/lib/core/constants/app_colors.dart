import 'package:flutter/material.dart';

import 'app_style.dart';

/// Paleta de cores de um estilo visual.
@immutable
class AppPalette {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.panel,
    required this.onPanel,
    required this.onPanelMuted,
    required this.decoration,
    required this.isDark,
  });

  /// Fundo da tela.
  final Color background;

  /// Superfície padrão de cards.
  final Color surface;

  /// Superfície elevada (chips, campos, trilhas de progresso).
  final Color surface2;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Linhas finas, bordas e divisores.
  final Color border;

  /// Painel de destaque (grafite no editorial, vidro forte no glass).
  final Color panel;
  final Color onPanel;
  final Color onPanelMuted;

  /// Cor do traço das formas decorativas (círculos, hachuras).
  final Color decoration;

  final bool isDark;

  /// Editorial — papel creme, tinta grafite, painéis escuros.
  static const editorial = AppPalette(
    background: Color(0xFFEDE5D8),
    surface: Color(0xFFF6F0E6),
    surface2: Color(0xFFE3D9CA),
    textPrimary: Color(0xFF2E2D2B),
    textSecondary: Color(0xFF6E685F),
    textTertiary: Color(0xFF9C958A),
    border: Color(0xFFD3C8B8),
    panel: Color(0xFF3B3A39),
    onPanel: Color(0xFFF2EBE0),
    onPanelMuted: Color(0xFFB5AEA3),
    decoration: Color(0xFF2E2D2B),
    isDark: false,
  );

  /// Liquid Glass — noite azulada com vidro translúcido.
  static const liquidGlass = AppPalette(
    background: Color(0xFF0B0D1A),
    surface: Color(0x1AFFFFFF),
    surface2: Color(0x24FFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFBFC3DD),
    textTertiary: Color(0xFF8E93B5),
    border: Color(0x33FFFFFF),
    panel: Color(0x2EFFFFFF),
    onPanel: Color(0xFFFFFFFF),
    onPanelMuted: Color(0xFFBFC3DD),
    decoration: Color(0xFFFFFFFF),
    isDark: true,
  );

  static AppPalette of(AppStyle style) => switch (style) {
        AppStyle.editorial => editorial,
        AppStyle.liquidGlass => liquidGlass,
      };
}

/// Tokens de cor e espaçamento do Daily Flow.
///
/// As cores dependem do [AppStyle] ativo e são trocadas por
/// [AppColors.use] (chamado pelo `DailyFlowApp` a cada build). Por isso
/// são *getters* e não `const` — não use `AppColors.<cor>` dentro de
/// expressões `const`.
class AppColors {
  AppColors._();

  static AppStyle _style = AppStyle.editorial;
  static AppPalette _p = AppPalette.editorial;

  /// Ativa a paleta do [style]. Seguro chamar a cada build.
  static void use(AppStyle style) {
    _style = style;
    _p = AppPalette.of(style);
  }

  static AppStyle get style => _style;
  static bool get isGlass => _style == AppStyle.liquidGlass;
  static AppPalette get palette => _p;

  // === Superfícies ===
  static Color get background => _p.background;
  static Color get surface => _p.surface;
  static Color get surface2 => _p.surface2;
  static Color get surfaceElevated => _p.surface2;

  // === Texto ===
  static Color get textPrimary => _p.textPrimary;
  static Color get textSecondary => _p.textSecondary;
  static Color get textTertiary => _p.textTertiary;

  // === Linhas ===
  static Color get border => _p.border;
  static Color get glassBorder => _p.border;

  // === Painel de destaque ===
  static Color get panel => _p.panel;
  static Color get onPanel => _p.onPanel;
  static Color get onPanelMuted => _p.onPanelMuted;
  static Color get decoration => _p.decoration;

  /// Véu translúcido no sentido do texto (escurece no claro, clareia
  /// no escuro). Substitui `Colors.white.withValues(alpha: x)`, que
  /// some no estilo editorial.
  static Color veil(double alpha) =>
      _p.textPrimary.withValues(alpha: alpha);

  /// Texto legível sobre uma cor sólida qualquer (ex.: accent).
  static Color onColor(Color c) =>
      c.computeLuminance() > 0.55 ? const Color(0xFF2E2D2B) : Colors.white;

  // === Spacing scale (4px base) ===
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;

  // === Border radius scale ===
  static const double radiusSm = 8;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
}
