import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../../settings/data/settings_controller.dart';
import '../../tasks/data/tasks_controller.dart';
import '../controllers/pomodoro_controller.dart';
import '../data/pomodoro_session_model.dart';
import 'pomodoro_timer_view.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(pomodoroTimerProvider);
    final controller = ref.read(pomodoroTimerProvider.notifier);
    final pendingTasks = ref
        .watch(tasksProvider)
        .where((t) => !t.isCompleted)
        .toList();
    final accent = ref.watch(accentColorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Timer de Foco')),
      body: Column(
        children: [
          Expanded(child: PomodoroTimerView(state: timer)),

          // Seletor de modo (Foco / Pausa Curta / Pausa Longa)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ModeSelector(
              current: timer.type,
              accent: accent,
              onChanged: controller.setType,
            ),
          ),
          const SizedBox(height: 16),

          // Vincular a uma tarefa (RF-PO-03)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LiquidGlassCard(
              child: Row(
                children: [
                  const Icon(Icons.bolt_outlined,
                      color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: timer.taskId,
                        hint: const Text('Vincular a uma tarefa'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Nenhuma'),
                          ),
                          for (final t in pendingTasks)
                            DropdownMenuItem<String?>(
                              value: t.id,
                              child: Text(
                                t.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: controller.selectTask,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Controles (RF-PO-01)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _GlassCircleButton(
                  icon: Icons.stop_rounded,
                  onPressed: controller.stop,
                ),
                _GlassCircleButton(
                  icon: timer.isRunning ? Icons.pause : Icons.play_arrow,
                  color: accent,
                  size: 84,
                  onPressed: controller.toggle,
                ),
                _GlassCircleButton(
                  icon: Icons.skip_next_rounded,
                  onPressed: controller.skip,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.current,
    required this.accent,
    required this.onChanged,
  });
  final PomodoroType current;
  final Color accent;
  final ValueChanged<PomodoroType> onChanged;

  @override
  Widget build(BuildContext context) {
    final accentDim = HSVColor.fromColor(accent).withValue(0.7).toColor();
    return RepaintBoundary(
      child: GlassContainer(
        shape: LiquidRoundedSuperellipse(borderRadius: 20),
        settings: LiquidGlassSettings(
          thickness: 10, // era 18
          blur: 8, // era 14
          glassColor: Colors.white.withValues(alpha: 0.18),
          lightIntensity: 0.5,
          glowIntensity: 0.5,
          fresnelStrength: 0.8,
          ambientRim: 0.4,
        ),
        useOwnLayer: true,
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            for (final type in PomodoroType.values)
              Expanded(
                child: _ModeChip(
                  label: _label(type),
                  active: current == type,
                  gradient: LinearGradient(
                    colors: [accent, accentDim],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => onChanged(type),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _label(PomodoroType type) => switch (type) {
        PomodoroType.focus => 'Foco',
        PomodoroType.shortBreak => 'Pausa Curta',
        PomodoroType.longBreak => 'Pausa Longa',
      };
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.active,
    required this.gradient,
    required this.onTap,
  });
  final String label;
  final bool active;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: active ? gradient : null,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({
    required this.icon,
    required this.onPressed,
    this.color = AppColors.surfaceElevated,
    this.size = 56,
  });
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      width: size,
      height: size,
      child: Icon(icon, color: AppColors.textPrimary, size: size * 0.45),
    );

    return RepaintBoundary(
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: 1.0,
        child: GlassContainer(
          shape: const LiquidOval(),
          settings: LiquidGlassSettings(
            thickness: 14, // era 26
            blur: 10, // era 20
            glassColor: color.withValues(alpha: 0.45),
            lightIntensity: 0.6,
            glowIntensity: 0.7,
            fresnelStrength: 1.0, // era 1.4
            chromaticAberration: 0.015, // era 0.03
            ambientRim: 0.5,
            shadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                offset: const Offset(0, 6),
                blurRadius: 16, // era 24
              ),
            ],
          ),
          useOwnLayer: true,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: child,
          ),
        ),
      ),
    );
  }
}
