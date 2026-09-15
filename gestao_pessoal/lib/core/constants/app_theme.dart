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

  /// DM Sans — base para todo o texto (títulos + corpo).
  static final TextStyle _base = GoogleFonts.dmSans(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w400,
  );

  /// Estilo para display (4xl = 48, 3xl = 36) — bold.
  static final TextStyle _displayBold = _base.copyWith(
    fontWeight: FontWeight.w700,
  );

  /// Estilo para títulos de seção (xl = 22) — semibold.
  static final TextStyle _headingSemibold = _base.copyWith(
    fontWeight: FontWeight.w600,
  );

  /// Estilo para labels (sm = 13) — medium.
  static final TextStyle _labelMedium = _base.copyWith(
    fontWeight: FontWeight.w500,
  );

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accentDim,
      tertiary: AppColors.primaryMuted,
      surface: AppColors.surface,
      onPrimary: AppColors.background,
      onSecondary: AppColors.background,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.textPrimary,
    );

    final textTheme = base.textTheme.copyWith(
      // 4xl = 48 — display (valores financeiros grandes)
      displayLarge: _displayBold.copyWith(fontSize: 48, height: 1.1),
      displayMedium: _displayBold.copyWith(fontSize: 36, height: 1.2),
      displaySmall: _displayBold.copyWith(fontSize: 36, height: 1.2),

      // 3xl = 36 — h1 (telas)
      headlineLarge: _displayBold.copyWith(fontSize: 36, height: 1.2),
      headlineMedium: _displayBold.copyWith(fontSize: 32, height: 1.25),
      headlineSmall: _headingSemibold.copyWith(fontSize: 22, height: 1.3),

      // xl = 22 — h2/h3 (títulos de seção)
      titleLarge: _headingSemibold.copyWith(fontSize: 22, height: 1.3),
      titleMedium: _headingSemibold.copyWith(fontSize: 18, height: 1.35),
      titleSmall: _headingSemibold.copyWith(fontSize: 16, height: 1.4),

      // base = 15 — body
      bodyLarge: _base.copyWith(fontSize: 15, height: 1.5),
      bodyMedium: _base.copyWith(fontSize: 14, height: 1.5),
      bodySmall: _base.copyWith(fontSize: 13, height: 1.5),

      // sm = 13 — label
      labelLarge: _labelMedium.copyWith(fontSize: 13, height: 1.4),
      labelMedium: _labelMedium.copyWith(fontSize: 12, height: 1.4),
      labelSmall: _labelMedium.copyWith(fontSize: 11, height: 1.4),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: AppColors.background,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _displayBold.copyWith(fontSize: 22),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
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
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryMuted;
          }
          return AppColors.surface2;
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: _labelMedium.copyWith(fontSize: 11),
        unselectedLabelStyle: _labelMedium.copyWith(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primaryMuted,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _labelMedium.copyWith(
              fontSize: 11,
              color: AppColors.primary,
            );
          }
          return _labelMedium.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(
            color: AppColors.textSecondary,
            size: 24,
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
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
        hintStyle: _base.copyWith(
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
        labelStyle: _base.copyWith(color: AppColors.textSecondary),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primaryMuted,
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