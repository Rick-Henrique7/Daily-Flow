import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/liquid_glass_card.dart';
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
                      color: AppColors.pinkIridescentStart),
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
                  color: AppColors.purpleFluidStart,
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
  const _ModeSelector({required this.current, required this.onChanged});
  final PomodoroType current;
  final ValueChanged<PomodoroType> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      shape: LiquidRoundedSuperellipse(borderRadius: 20),
      settings: LiquidGlassSettings(
        thickness: 18,
        blur: 14,
        glassColor: Colors.white.withValues(alpha: 0.18),
        lightIntensity: 0.6,
        glowIntensity: 0.6,
        fresnelStrength: 1.0,
        ambientRim: 0.5,
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
                onTap: () => onChanged(type),
              ),
            ),
        ],
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
    required this.onTap,
  });
  final String label;
  final bool active;
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
          gradient: active ? AppColors.purpleFluid : null,
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

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: 1.0,
      child: GlassContainer(
        shape: const LiquidOval(),
        settings: LiquidGlassSettings(
          thickness: 26,
          blur: 20,
          glassColor: color.withValues(alpha: 0.55),
          lightIntensity: 0.8,
          glowIntensity: 1.0,
          fresnelStrength: 1.4,
          chromaticAberration: 0.03,
          ambientRim: 0.7,
          shadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              offset: const Offset(0, 8),
              blurRadius: 24,
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
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 1500.ms, color: AppColors.glassBorder);
  }
}
