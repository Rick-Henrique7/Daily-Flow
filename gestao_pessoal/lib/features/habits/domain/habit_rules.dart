import '../../../core/utils/date_only.dart';
import 'habit_model.dart';

/// Regras de sequência (streak) — funções puras, testadas em
/// `test/features/habits/habit_rules_test.dart`.
///
/// A sequência é **calculada** a partir de `completedDates`, nunca
/// gravada: antes o número salvo só mudava ao marcar/desmarcar, então
/// quem ficava dias sem abrir o app continuava vendo a sequência antiga.
abstract final class HabitStreak {
  /// Sequência atual do hábito em [today].
  ///
  /// Conta, de hoje para trás, os **dias previstos** (`frequencyDays`)
  /// concluídos seguidos. Dias fora da frequência não quebram nem somam.
  /// Hoje ainda não feito também não quebra — o dia ainda está aberto.
  static int current(HabitModel habit, DateTime today) {
    if (habit.frequencyDays.isEmpty || habit.completedDates.isEmpty) return 0;
    final done = {for (final d in habit.completedDates) dateOnly(d)};
    final earliest = done.reduce((a, b) => a.isBefore(b) ? a : b);

    var day = dateOnly(today);
    var streak = 0;
    if (habit.isScheduledFor(day) && done.contains(day)) streak++;

    while (true) {
      day = DateTime(day.year, day.month, day.day - 1);
      if (day.isBefore(earliest)) break;
      if (!habit.isScheduledFor(day)) continue;
      if (!done.contains(day)) break;
      streak++;
    }
    return streak;
  }

  /// Maior sequência atual entre todos os hábitos.
  static int best(List<HabitModel> habits, DateTime today) {
    var best = 0;
    for (final h in habits) {
      final s = current(h, today);
      if (s > best) best = s;
    }
    return best;
  }
}

/// Regras do calendário de hábitos.
abstract final class HabitCalendar {
  /// Dias (últimos [days] até [today]) em que pelo menos um hábito
  /// previsto **não** foi concluído — pintados no calendário.
  static Set<DateTime> incompleteDays(
    List<HabitModel> habits,
    DateTime today, {
    int days = 90,
  }) {
    if (habits.isEmpty) return <DateTime>{};
    // Pré-computa os dias feitos de cada hábito (antes era uma busca
    // linear em completedDates para cada dia × hábito, a cada build).
    final doneSets = [
      for (final h in habits) {for (final d in h.completedDates) dateOnly(d)},
    ];
    final start = dateOnly(today);
    final result = <DateTime>{};
    for (var i = 0; i <= days; i++) {
      final day = DateTime(start.year, start.month, start.day - i);
      for (var j = 0; j < habits.length; j++) {
        if (habits[j].isScheduledFor(day) && !doneSets[j].contains(day)) {
          result.add(day);
          break;
        }
      }
    }
    return result;
  }
}
