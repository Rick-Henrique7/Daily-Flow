import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../habits/data/habits_controller.dart';
import '../../pomodoro/data/pomodoro_controller.dart';
import '../../pomodoro/domain/pomodoro_session_model.dart';
import '../../settings/data/settings_controller.dart';
import '../../tasks/data/tasks_controller.dart';
import '../../tasks/domain/task_model.dart';

enum StatsPeriod { weekly, monthly, yearly }

final _statsPeriodProvider = StateProvider<StatsPeriod>((ref) => StatsPeriod.weekly);

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(_statsPeriodProvider);
    final tasks = ref.watch(tasksProvider);
    final habits = ref.watch(habitsProvider);
    final sessions = ref.watch(pomodoroHistoryProvider);
    final accent = ref.watch(accentColorProvider);

    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalMinutes = sessions
        .where((s) => s.isCompleted && s.type == PomodoroType.focus)
        .fold<int>(0, (acc, s) => acc + s.durationMinutes);
    final streak = habits.isEmpty
        ? 0
        : habits.map((h) => h.streakCount).reduce((a, b) => a > b ? a : b);

    // Agrupamento para gráfico de barras (produtividade diária)
    final dailyBars = _dailyBars(tasks, period);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
          const ScreenHeader(
            eyebrow: 'Seu progresso',
            title: 'Estatísticas',
            padding: EdgeInsets.fromLTRB(4, 12, 4, 16),
          ),
          // Filtro de período (RF-ST-01)
          SegmentedButton<StatsPeriod>(
            segments: const [
              ButtonSegment(value: StatsPeriod.weekly, label: Text('Semana')),
              ButtonSegment(value: StatsPeriod.monthly, label: Text('Mês')),
              ButtonSegment(value: StatsPeriod.yearly, label: Text('Ano')),
            ],
            selected: {period},
            onSelectionChanged: (s) =>
                ref.read(_statsPeriodProvider.notifier).state = s.first,
          ),
          const SizedBox(height: 16),

          // KPIs — painel com número grande + dois secundários
          LiquidGlassCard(
            panel: true,
            borderRadius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarefas concluídas',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: accent),
                ),
                Text(
                  completedTasks.toString().padLeft(2, '0'),
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(color: accent, fontSize: 80),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: AppColors.onPanel.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _KpiCard(
                        label: 'Minutos de foco',
                        value: '$totalMinutes',
                        icon: Icons.timer_outlined,
                      ),
                    ),
                    Expanded(
                      child: _KpiCard(
                        label: 'Maior sequência',
                        value: '$streak ${streak == 1 ? 'dia' : 'dias'}',
                        icon: Icons.local_fire_department_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Gráfico de barras (RF-ST-02) — customizado com Flutter puro
          // para evitar sobreposição de labels do fl_chart.
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produtividade diária',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _CustomBarChart(
                    data: dailyBars,
                    period: period,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Heatmap (RF-ST-03) — últimas 8 semanas
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consistência',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _Heatmap(habits: habits),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  List<_DailyCount> _dailyBars(List<TaskModel> tasks, StatsPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = switch (period) {
      StatsPeriod.weekly => 7,
      StatsPeriod.monthly => 30,
      StatsPeriod.yearly => 12,
    };
    return List.generate(days, (i) {
      final day = switch (period) {
        StatsPeriod.yearly =>
          DateTime(today.year, today.month - (days - 1 - i), today.day),
        _ => today.subtract(Duration(days: days - 1 - i)),
      };
      final count = tasks.where((t) {
        final c = t.completedAt;
        if (c == null) return false;
        return DateFormatters.isSameDay(c, day);
      }).length;
      return _DailyCount(day: day, count: count);
    });
  }
}

class _DailyCount {
  _DailyCount({required this.day, required this.count});
  final DateTime day;
  final int count;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: AppColors.onPanelMuted, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: t.titleLarge?.copyWith(color: AppColors.onPanel),
              ),
              Text(
                label,
                style: t.labelMedium?.copyWith(color: AppColors.onPanelMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// BarChart customizado com Flutter puro.
///
/// Substitui o `BarChart` do fl_chart porque mesmo com `interval` no
/// SideTitles, a versão 0.68 ainda renderiza todos os labels
/// sobrepostos em eixos categóricos. Aqui controlamos exatamente
/// quantos labels aparecem com base no período selecionado.
class _CustomBarChart extends ConsumerWidget {
  const _CustomBarChart({required this.data, required this.period});
  final List<_DailyCount> data;
  final StatsPeriod period;

  /// Quais índices de data devem mostrar label no eixo X.
  List<int> _labelIndices() {
    if (data.isEmpty) return const [];
    final n = data.length;
    return switch (period) {
      StatsPeriod.weekly =>
        List.generate(n, (i) => i), // todos os 7
      StatsPeriod.monthly => [
        for (var i = 0; i < n; i++) if (i % 5 == 0) i,
        if (n - 1 % 5 != 0 && !((n - 1) % 5 == 0)) n - 1,
      ],
      StatsPeriod.yearly => List.generate(n, (i) => i),
    };
  }

  String _labelFor(DateTime day) {
    return switch (period) {
      StatsPeriod.weekly =>
        DateFormat('E', 'pt_BR').format(day).substring(0, 1),
      StatsPeriod.monthly => '${day.day}',
      StatsPeriod.yearly => DateFormat('MMM', 'pt_BR').format(day),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Sem dados',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    final accent = ref.watch(accentColorProvider);
    final accentDim = HSVColor.fromColor(accent).withValue(0.7).toColor();
    final maxValue =
        data.fold<int>(0, (acc, e) => e.count > acc ? e.count : acc);
    final labelsToShow = _labelIndices().toSet();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < data.length; i++) ...[
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          margin: EdgeInsets.symmetric(
                            horizontal: data.length > 12 ? 1 : 6,
                          ),
                          duration: const Duration(milliseconds: 400),
                          height: maxValue == 0
                              ? 4
                              : (data[i].count / maxValue) *
                                  (constraints.maxHeight - 20) +
                                  4,
                          decoration: BoxDecoration(
                            // Editorial: barras grafite e o melhor dia em
                            // accent. Glass: fade de opacidade do accent.
                            color: AppColors.isGlass
                                ? null
                                : (data[i].count == maxValue && maxValue > 0
                                    ? accent
                                    : AppColors.textPrimary
                                        .withValues(alpha: 0.75)),
                            gradient: AppColors.isGlass
                                ? LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [accentDim, accent],
                                  )
                                : null,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 18,
              child: Row(
                children: [
                  for (var i = 0; i < data.length; i++)
                    Expanded(
                      child: Center(
                        child: labelsToShow.contains(i)
                            ? Text(
                                _labelFor(data[i].day),
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Heatmap extends ConsumerWidget {
  const _Heatmap({required this.habits});
  final List habits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 55));
    final completedDays = <DateTime>{};
    for (final h in habits) {
      for (final d in h.completedDates as List) {
        completedDays.add(DateTime(d.year, d.month, d.day));
      }
    }

    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: List.generate(56, (i) {
        final day = start.add(Duration(days: i));
        final completed = completedDays.contains(day);
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: completed
                ? accent.withValues(alpha: 0.85)
                : AppColors.veil(0.08),
            borderRadius: BorderRadius.circular(7),
          ),
        );
      }),
    );
  }
}
