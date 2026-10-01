import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_pessoal/features/pomodoro/domain/pomodoro_session_model.dart';
import 'package:gestao_pessoal/features/stats/domain/stats_calculator.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('conclusões de recorrentes contam uma vez por dia', () {
    final tasks = [
      task(id: 'a', isCompleted: true, completedAt: thu),
      task(id: 'b', repeatDays: const [2, 4], completedDates: [tue, thu]),
      task(id: 'c'), // aberta
    ];
    expect(StatsCalculator.taskCompletions(tasks), hasLength(3));
  });

  test('gráfico semanal: 7 barras terminando hoje', () {
    final bars = StatsCalculator.bars([thu, thu, wed], StatsPeriod.weekly, thu);
    expect(bars, hasLength(7));
    expect(bars.last.day, thu);
    expect(bars.last.count, 2);
    expect(bars[5].count, 1);
  });

  test('gráfico anual soma o mês inteiro (bug antigo: só o mesmo dia)', () {
    final completions = [
      DateTime(2026, 10, 1),
      DateTime(2026, 10, 15),
      DateTime(2026, 9, 3),
    ];
    final bars = StatsCalculator.bars(completions, StatsPeriod.yearly, thu);
    expect(bars, hasLength(12));
    expect(bars.last.count, 2); // outubro
    expect(bars[10].count, 1); // setembro
  });

  test('minutos de foco somam só sessões de foco concluídas', () {
    PomodoroSessionModel s(PomodoroType type, int min) => PomodoroSessionModel(
          id: '$type$min',
          taskId: null,
          startTime: thu,
          durationMinutes: min,
          isCompleted: true,
          type: type,
        );
    final sessions = [
      s(PomodoroType.focus, 25),
      s(PomodoroType.focus, 25),
      s(PomodoroType.shortBreak, 5),
    ];
    expect(StatsCalculator.focusMinutes(sessions), 50);
  });
}
