import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Card flat dark do Daily Flow.
///
/// Design system "Financial App — Dark/Green":
/// - Surface: `#141414` (bg-surface)
/// - Border: 1px `#1E1E1E` (border)
/// - Radius: 16px (radius-md)
/// - Sem drop shadows — depth via color contrast
/// - Padding interno padrão: 20px (space5)
///
/// `RepaintBoundary` interno isola cada card do paint do background.
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppColors.space5),
    this.borderRadius = AppColors.radiusMd,
    this.gradient,
    this.intensity = GlassIntensity.standard,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Gradient? gradient;
  final GlassIntensity intensity;

  @override
  Widget build(BuildContext context) {
    final bg = gradient == null
        ? (intensity == GlassIntensity.subtle
            ? AppColors.background
            : AppColors.surface)
        : null;
    return RepaintBoundary(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Mantido p/ compatibilidade — `subtle` usa `background`,
/// `standard`/`strong` usam `surface`.
enum GlassIntensity { subtle, standard, strong }