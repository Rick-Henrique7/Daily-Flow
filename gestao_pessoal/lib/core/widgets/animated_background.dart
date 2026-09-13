import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/data/settings_controller.dart';
import '../constants/app_colors.dart';

/// Background animado com blobs (manchas) de gradiente.
///
/// Pinta 3 elipses que se movem lentamente em loop. As cores são
/// derivadas da configuração do usuário (`settings.wallpaperSeed`),
/// então trocar o wallpaper nas Configurações muda os blobs em tempo
/// real. O resultado é a sensação de vidro sobre cor, fundamental
/// para o visual Liquid Glass 3D.
class AnimatedBackground extends ConsumerStatefulWidget {
  const AnimatedBackground({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends ConsumerState<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Converte hex `#RRGGBB` em `Color`.
  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final seed = _hexToColor(settings.wallpaperSeed);
    final intensity = settings.blobIntensity;

    // Cores dos 3 blobs: seed + 2 harmonizadas.
    final complement = HSVColor.fromColor(seed)
        .withHue((HSVColor.fromColor(seed).hue + 60) % 360)
        .withSaturation(1)
        .withValue(1)
        .toColor();
    final accent = HSVColor.fromColor(seed)
        .withHue((HSVColor.fromColor(seed).hue + 180) % 360)
        .withSaturation(0.8)
        .withValue(1)
        .toColor();

    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: AppColors.background),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _BlobsPainter(
                  t: _controller.value,
                  blobColors: [
                    seed.withValues(alpha: intensity),
                    complement.withValues(alpha: intensity * 0.85),
                    accent.withValues(alpha: intensity * 0.75),
                  ],
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _BlobsPainter extends CustomPainter {
  _BlobsPainter({required this.t, required this.blobColors});
  final double t;
  final List<Color> blobColors;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final positions = [
      _Point(
        x: 0.25 + 0.10 * math.sin(t * 2 * math.pi),
        y: 0.30 + 0.08 * math.cos(t * 2 * math.pi),
        radius: math.max(w, h) * 0.55,
        color: blobColors[0],
      ),
      _Point(
        x: 0.80 + 0.12 * math.cos(t * 2 * math.pi + 1.5),
        y: 0.75 + 0.10 * math.sin(t * 2 * math.pi + 1.5),
        radius: math.max(w, h) * 0.50,
        color: blobColors[1],
      ),
      _Point(
        x: 0.55 + 0.14 * math.sin(t * 2 * math.pi + 3.0),
        y: 0.10 + 0.12 * math.cos(t * 2 * math.pi + 3.0),
        radius: math.max(w, h) * 0.45,
        color: blobColors[2],
      ),
    ];

    for (final blob in positions) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [blob.color, blob.color.withValues(alpha: 0)],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(blob.x * w, blob.y * h),
            radius: blob.radius,
          ),
        )
        ..blendMode = BlendMode.plus;
      canvas.drawCircle(
        Offset(blob.x * w, blob.y * h),
        blob.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BlobsPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.blobColors != blobColors;
}

class _Point {
  _Point({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
  });
  final double x;
  final double y;
  final double radius;
  final Color color;
}
