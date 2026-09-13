import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tema central do Daily Flow.
///
/// Aplica Dark Mode nativo por padrão, fontes modernas via google_fonts
/// e configurações globais para micro-interações responsivas.
class AppTheme {
  AppTheme._();

  /// Família para títulos/timer (display, com personalidade).
  static final TextStyle _displayBase = GoogleFonts.spaceGrotesk(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w600,
  );

  /// Família para corpo de texto (clean, legível).
  static final TextStyle _bodyBase = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    final colorScheme = ColorScheme.dark(
      primary: AppColors.purpleFluidStart,
      secondary: AppColors.cyanWaterStart,
      tertiary: AppColors.pinkIridescentStart,
      surface: AppColors.surface,
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.textPrimary,
    );

    final textTheme = base.textTheme.copyWith(
      displayLarge: _displayBase.copyWith(
        fontSize: 72,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
      ),
      displayMedium: _displayBase.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      displaySmall: _displayBase.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineLarge: _displayBase.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: _displayBase.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineSmall: _displayBase.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: _displayBase.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: _bodyBase.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: _bodyBase.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: _bodyBase.copyWith(fontSize: 16),
      bodyMedium: _bodyBase.copyWith(fontSize: 14),
      bodySmall: _bodyBase.copyWith(fontSize: 12),
      labelLarge: _bodyBase.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: _bodyBase.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
      labelSmall: _bodyBase.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
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
        centerTitle: false,
        titleTextStyle: _displayBase.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      dividerColor: AppColors.textTertiary.withValues(alpha: 0.3),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.purpleFluidStart;
          }
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.purpleFluidStart.withValues(alpha: 0.4);
          }
          return AppColors.surfaceElevated;
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.purpleFluidStart,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.purpleFluidStart,
        foregroundColor: AppColors.textPrimary,
        elevation: 6,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.purpleFluidStart,
            width: 1.5,
          ),
        ),
        hintStyle: _bodyBase.copyWith(
          color: AppColors.textTertiary.withValues(alpha: 0.7),
        ),
        labelStyle: _bodyBase.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
