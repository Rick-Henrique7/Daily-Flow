import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../controllers/pomodoro_controller.dart';
import '../data/pomodoro_session_model.dart';

/// Timer circular minimalista do Pomodoro (RF-PO-01, RNF-PO-01).
///
/// Usa [CustomPaint] otimizado (sem AnimatedContainer) e mantém
/// `TweenAnimationBuilder` apenas para o gradiente do anel.
///
/// O conteúdo (label + tempo) é centralizado usando [Center] + [Column]
/// com `crossAxisAlignment: stretch` + texto com `textAlign: center`,
/// garantindo alinhamento perfeito mesmo em larguras variáveis.
class PomodoroTimerView extends StatelessWidget {
  const PomodoroTimerView({super.key, required this.state});

  final PomodoroTimerState state;

  Color get _accentColor {
    switch (state.type) {
      case PomodoroType.focus:
        return AppColors.pinkIridescentStart;
      case PomodoroType.shortBreak:
        return AppColors.cyanWaterStart;
      case PomodoroType.longBreak:
        return AppColors.success;
    }
  }

  String get _label {
    switch (state.type) {
      case PomodoroType.focus:
        return 'FOCO';
      case PomodoroType.shortBreak:
        return 'PAUSA CURTA';
      case PomodoroType.longBreak:
        return 'PAUSA LONGA';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Anel desenhado.
              Positioned.fill(
                child: CustomPaint(
                  painter: _TimerPainter(
                    progress: state.progress,
                    color: _accentColor,
                  ),
                ),
              ),
              // Conteúdo centralizado.
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                      color: _accentColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    DateFormatters.pomodoro(state.remainingSeconds),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 76,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -2,
                      height: 1.0,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: AppColors.textPrimary,
                    ),
                  )
                      .animate(target: state.isRunning ? 1 : 0)
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.02, 1.02),
                      ),
                  const SizedBox(height: 8),
                  Text(
                    '${(state.progress * 100).round()}%',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  _TimerPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 14;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    final track = Paint()
      ..color = AppColors.surfaceElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius, track);

    // Progress
    final shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [color.withValues(alpha: 0.6), color],
    ).createShader(rect);

    final progressPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
