import '../../../core/utils/date_only.dart';
import '../../habits/domain/habit_model.dart';
import '../../habits/domain/habit_rules.dart';
import '../../pomodoro/domain/pomodoro_session_model.dart';
import '../../tasks/domain/task_model.dart';

/// Período do gráfico de produtividade.
enum StatsPeriod { weekly, monthly, yearly }

/// Uma barra do gráfico: um dia (semana/mês) ou um mês (ano).
class DailyCount {
  const DailyCount({required this.day, required this.count});

  final DateTime day;
  final int count;
}

/// Números da tela de Estatísticas, já calculados.
class StatsSummary {
  const StatsSummary({
    required this.completedTasks,
    required this.focusMinutes,
    required this.bestStreak,
    required this.bars,
    required this.habitDays,
  });

  final int completedTasks;
  final int focusMinutes;
  final int bestStreak;
  final List<DailyCount> bars;

  /// Dias em que algum hábito foi concluído (heatmap).
  final Set<DateTime> habitDays;
}

/// Agregações das estatísticas — funções puras (antes ficavam dentro
/// do `build` da tela). Testadas em `test/features/stats/`.
abstract final class StatsCalculator {
  /// Cada conclusão de tarefa vira uma data: pontual = `completedAt`;
  /// recorrente = cada dia em `completedDates`.
  static List<DateTime> taskCompletions(List<TaskModel> tasks) => [
        for (final t in tasks)
          if (t.isRepeating)
            ...t.completedDates.map(dateOnly)
          else if (t.isCompleted && t.completedAt != null)
            dateOnly(t.completedAt!),
      ];

  /// Minutos de foco em sessões concluídas.
  static int focusMinutes(List<PomodoroSessionModel> sessions) => sessions
      .where((s) => s.isCompleted && s.type == PomodoroType.focus)
      .fold<int>(0, (acc, s) => acc + s.durationMinutes);

  /// Barras do gráfico. Semana = 7 dias, mês = 30 dias, ano = 12 meses
  /// (no ano, cada barra soma o **mês inteiro** — antes contava só o
  /// mesmo dia do mês, o que zerava quase todas as barras).
  static List<DailyCount> bars(
    List<DateTime> completions,
    StatsPeriod period,
    DateTime today,
  ) {
    final t = dateOnly(today);
    if (period == StatsPeriod.yearly) {
      return List.generate(12, (i) {
        final month = DateTime(t.year, t.month - (11 - i));
        final count = completions
            .where((c) => c.year == month.year && c.month == month.month)
            .length;
        return DailyCount(day: month, count: count);
      });
    }
    final days = period == StatsPeriod.weekly ? 7 : 30;
    final perDay = <DateTime, int>{};
    for (final c in completions) {
      final d = dateOnly(c);
      perDay[d] = (perDay[d] ?? 0) + 1;
    }
    return List.generate(days, (i) {
      final day = DateTime(t.year, t.month, t.day - (days - 1 - i));
      return DailyCount(day: day, count: perDay[day] ?? 0);
    });
  }

  /// Dias com pelo menos um hábito concluído.
  static Set<DateTime> habitDays(List<HabitModel> habits) => {
        for (final h in habits) ...h.completedDates.map(dateOnly),
      };

  static StatsSummary summarize({
    required List<TaskModel> tasks,
    required List<HabitModel> habits,
    required List<PomodoroSessionModel> sessions,
    required StatsPeriod period,
    required DateTime today,
  }) {
    final completions = taskCompletions(tasks);
    return StatsSummary(
      completedTasks: completions.length,
      focusMinutes: focusMinutes(sessions),
      bestStreak: HabitStreak.best(habits, today),
      bars: bars(completions, period, today),
      habitDays: habitDays(habits),
    );
  }
}
