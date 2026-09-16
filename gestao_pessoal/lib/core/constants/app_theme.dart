import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tema central do Daily Flow.
///
/// Baseado no design system "Financial App — Dark/Green":
/// - Fonte única: **DM Sans** (geometric sans-serif)
/// - Min weight: **400** (nada abaixo disso)
/// - Accent único: neon green (#00E676)
/// - Borders low-contrast (#1E1E1E, 1px)
/// - Sem drop shadows (depth via color contrast)
/// - Sem uppercase labels — sentence case only
class AppTheme {
  AppTheme._();

  /// Converte hex `#RRGGBB` em `Color`.
  static Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  /// DM Sans — base para todo o texto (títulos + corpo).
  /// Recebe a cor primária (customizada ou default) por parâmetro.
  static TextStyle _base(Color foreground) => GoogleFonts.dmSans(
        color: foreground,
        fontWeight: FontWeight.w400,
      );

  /// Estilo para display (4xl = 48, 3xl = 36) — bold.
  static TextStyle _displayBold(Color foreground) => _base(foreground).copyWith(
        fontWeight: FontWeight.w700,
      );

  /// Estilo para títulos de seção (xl = 22) — semibold.
  static TextStyle _headingSemibold(Color foreground) =>
      _base(foreground).copyWith(fontWeight: FontWeight.w600);

  /// Estilo para labels (sm = 13) — medium.
  static TextStyle _labelMedium(Color foreground) => _base(foreground).copyWith(
    fontWeight: FontWeight.w500,
  );

  static ThemeData get dark => darkWith();

  /// Versão parametrizada — aceita `textColorHex` (ex: `#FFEB3B`) p/
  /// customizar a cor primária do texto, e `accentColorHex` (ex:
  /// `#FF6B6B`) p/ customizar o accent (default `#00E676` neon green).
  /// Se ambos `null`, usa o design system default.
  static ThemeData darkWith({String? textColorHex, String? accentColorHex}) {
    final base = ThemeData.dark(useMaterial3: true);
    final foreground = _hexToColor(textColorHex ?? '#FFFFFF');
    final accent = _hexToColor(accentColorHex ?? '#00E676');
    final accentDim = HSVColor.fromColor(accent)
        .withValue(0.7)
        .toColor();
    final accentMuted = HSVColor.fromColor(accent)
        .withSaturation(0.5)
        .withValue(0.2)
        .toColor();

    final colorScheme = ColorScheme.dark(
      primary: accent,
      secondary: accentDim,
      tertiary: accentMuted,
      surface: AppColors.surface,
      onPrimary: AppColors.background,
      onSecondary: AppColors.background,
      onSurface: foreground,
      error: AppColors.danger,
      onError: AppColors.textPrimary,
    );

    final textTheme = base.textTheme.copyWith(
      // 4xl = 48 — display (valores financeiros grandes)
      displayLarge: _displayBold(foreground).copyWith(fontSize: 48, height: 1.1),
      displayMedium: _displayBold(foreground).copyWith(fontSize: 36, height: 1.2),
      displaySmall: _displayBold(foreground).copyWith(fontSize: 36, height: 1.2),

      // 3xl = 36 — h1 (telas)
      headlineLarge: _displayBold(foreground).copyWith(fontSize: 36, height: 1.2),
      headlineMedium: _displayBold(foreground).copyWith(fontSize: 32, height: 1.25),
      headlineSmall:
          _headingSemibold(foreground).copyWith(fontSize: 22, height: 1.3),

      // xl = 22 — h2/h3 (títulos de seção)
      titleLarge:
          _headingSemibold(foreground).copyWith(fontSize: 22, height: 1.3),
      titleMedium:
          _headingSemibold(foreground).copyWith(fontSize: 18, height: 1.35),
      titleSmall:
          _headingSemibold(foreground).copyWith(fontSize: 16, height: 1.4),

      // base = 15 — body
      bodyLarge: _base(foreground).copyWith(fontSize: 15, height: 1.5),
      bodyMedium: _base(foreground).copyWith(fontSize: 14, height: 1.5),
      bodySmall: _base(foreground).copyWith(fontSize: 13, height: 1.5),

      // sm = 13 — label
      labelLarge: _labelMedium(foreground).copyWith(fontSize: 13, height: 1.4),
      labelMedium: _labelMedium(foreground).copyWith(fontSize: 12, height: 1.4),
      labelSmall: _labelMedium(foreground).copyWith(fontSize: 11, height: 1.4),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: AppColors.background,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: foreground),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _displayBold(foreground).copyWith(fontSize: 22),
        iconTheme: IconThemeData(color: foreground),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dividerColor: AppColors.border,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentMuted;
          }
          return AppColors.surface2;
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: accent,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: _labelMedium(foreground).copyWith(fontSize: 11),
        unselectedLabelStyle: _labelMedium(foreground).copyWith(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: accentMuted,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _labelMedium(foreground).copyWith(
              fontSize: 11,
              color: accent,
            );
          }
          return _labelMedium(foreground).copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: accent, size: 24);
          }
          return const IconThemeData(
            color: AppColors.textSecondary,
            size: 24,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: AppColors.background,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppColors.radiusMd)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppColors.space5,
          vertical: AppColors.space3,
        ),
        hintStyle: _base(foreground).copyWith(
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
        labelStyle: _base(foreground).copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: AppColors.border,
        thumbColor: accent,
        overlayColor: accentMuted,
        trackHeight: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppColors.radiusLg),
          ),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }
}