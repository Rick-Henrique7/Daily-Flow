import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/data/settings_controller.dart';
import '../../features/settings/domain/app_settings.dart';
import '../constants/app_colors.dart';

/// Background da tela. Dois modos:
/// - [WallpaperMode.animated] — gradiente com 3 blobs se movendo em
///   loop infinito (default; visual Liquid Glass 3D).
/// - [WallpaperMode.solid] — cor única estática. Sem animação, sem
///   `CustomPaint`, sem custo de GPU.
///
/// Otimizações (modo animado):
/// - Shaders são cacheados por `(tamanho, cor)` para evitar realocações
///   de `RadialGradient.createShader` a cada frame
///   (antes: 3 alocações/frame = ~180/seg a 60fps).
/// - `RepaintBoundary` isola o repaint do background do conteúdo da
///   tela — navegar entre abas não recompila os filhos do shell.
/// - As posições dos blobs são pré-computadas fora do loop.
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
    );
    // Só repete se o modo inicial for animado; se for sólido,
    // fica parado (sem custo).
    final initial = ref.read(settingsProvider).wallpaperMode;
    if (initial == WallpaperMode.animated) {
      _controller.repeat();
    }
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

    // Sincroniza o ticker com o modo: liga se ficou animado, desliga
    // caso contrário. Sem isso, mudar do sólido pro animado não
    // reiniciaria a animação.
    if (settings.wallpaperMode == WallpaperMode.animated &&
        !_controller.isAnimating) {
      _controller.repeat();
    } else if (settings.wallpaperMode != WallpaperMode.animated &&
        _controller.isAnimating) {
      _controller.stop();
    }

    if (settings.wallpaperMode == WallpaperMode.solid) {
      return _buildSolid(settings.wallpaperSolidColor);
    }
    return _buildAnimated(settings);
  }

  /// Fundo sólido: 1 `ColoredBox`, sem GPU, sem ticker.
  Widget _buildSolid(String hex) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: ColoredBox(color: _hexToColor(hex)),
          ),
        ),
        RepaintBoundary(child: widget.child),
      ],
    );
  }

  /// Fundo animado: blobs gradiente em loop (default).
  Widget _buildAnimated(AppSettings settings) {
    final seed = _hexToColor(settings.wallpaperSeed);
    final intensity = settings.blobIntensity;

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

    final blobColors = <Color>[
      seed.withValues(alpha: intensity),
      complement.withValues(alpha: intensity * 0.85),
      accent.withValues(alpha: intensity * 0.75),
    ];

    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: AppColors.background),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _BlobsPainter(
                    t: _controller.value,
                    blobColors: blobColors,
                  ),
                );
              },
            ),
          ),
        ),
        RepaintBoundary(child: widget.child),
      ],
    );
  }
}

class _BlobsPainter extends CustomPainter {
  _BlobsPainter({required this.t, required this.blobColors});

  final double t;
  final List<Color> blobColors;

  // Cache de shaders por (tamanho, cor inicial). Chave = "WxH:#RRGGBB:#RRGGBB:#RRGGBB"
  // O shader depende só do tamanho + cor inicial (RadialGradient usa a cor
  // como center e transparente como edge), então cachear aqui evita criar
  // ~180 Shader objects/segundo no loop de animação.
  static final Map<String, ui.Shader> _shaderCache = {};

  String _cacheKey(Size size, Color color) {
    return '${size.width.toInt()}x${size.height.toInt()}:'
        '${color.toARGB32()}';
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final twoPi = 2 * math.pi;

    // Pré-computa as 3 posições fora do loop (era recomputado a cada blob)
    final positions = <_Point>[
      _Point(
        x: 0.25 + 0.10 * math.sin(t * twoPi),
        y: 0.30 + 0.08 * math.cos(t * twoPi),
        radius: math.max(w, h) * 0.55,
        color: blobColors[0],
      ),
      _Point(
        x: 0.80 + 0.12 * math.cos(t * twoPi + 1.5),
        y: 0.75 + 0.10 * math.sin(t * twoPi + 1.5),
        radius: math.max(w, h) * 0.50,
        color: blobColors[1],
      ),
      _Point(
        x: 0.55 + 0.14 * math.sin(t * twoPi + 3.0),
        y: 0.10 + 0.12 * math.cos(t * twoPi + 3.0),
        radius: math.max(w, h) * 0.45,
        color: blobColors[2],
      ),
    ];

    for (final blob in positions) {
      final center = Offset(blob.x * w, blob.y * h);
      final key = _cacheKey(size, blob.color);
      final shader = _shaderCache.putIfAbsent(
        key,
        () => RadialGradient(
          colors: [blob.color, blob.color.withValues(alpha: 0)],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: blob.radius)),
      );

      // Reaproveita o mesmo Paint object (campos são imutáveis por frame aqui)
      final paint = Paint()
        ..shader = shader
        ..blendMode = BlendMode.plus;
      canvas.drawCircle(center, blob.radius, paint);
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