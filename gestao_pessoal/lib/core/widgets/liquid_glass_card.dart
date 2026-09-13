import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Wrapper do Liquid Glass para o design system do Daily Flow.
///
/// Encapsula o `GlassContainer` da lib `liquid_glass_widgets` (iOS 26
/// design language) com defaults consistentes — bordas vítreas, sombras
/// 3D profundas e gradientes iridescentes sutis.
///
/// Usa `useOwnLayer: true` para que cada card tenha suas próprias
/// configurações de glass independentes do layer pai.
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 28,
    this.gradient,
    this.intensity = GlassIntensity.standard,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Gradient? gradient;
  final GlassIntensity intensity;

  LiquidGlassSettings get _settings {
    final factor = switch (intensity) {
      GlassIntensity.subtle => 0.6,
      GlassIntensity.standard => 1.0,
      GlassIntensity.strong => 1.4,
    };
    return LiquidGlassSettings(
      thickness: 30 * factor,
      blur: switch (intensity) {
        GlassIntensity.subtle => 8,
        GlassIntensity.standard => 18,
        GlassIntensity.strong => 32,
      },
      glassColor: Colors.white.withValues(alpha: 0.22),
      lightIntensity: 0.7,
      glowIntensity: 0.85,
      fresnelStrength: 1.2,
      chromaticAberration: 0.02,
      ambientStrength: 0.12,
      ambientRim: 0.6,
      saturation: 1.6,
      shadow: const [
        BoxShadow(
          color: Color(0x30000000),
          offset: Offset(12, 18),
          blurRadius: 30,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: Color(0x14000000),
          offset: Offset(-5, -5),
          blurRadius: 10,
        ),
      ],
      whitenStrength: 0.05,
      edgeAbsorption: 0.12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
      settings: _settings,
      useOwnLayer: true,
      padding: padding,
      child: child,
    );
  }
}

enum GlassIntensity { subtle, standard, strong }
