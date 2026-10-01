import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../habits/data/habits_controller.dart';
import '../../pomodoro/data/pomodoro_controller.dart';
import '../../tasks/data/tasks_controller.dart';
import '../domain/stats_calculator.dart';

export '../domain/stats_calculator.dart';

/// Período selecionado no gráfico.
final statsPeriodProvider =
    StateProvider<StatsPeriod>((ref) => StatsPeriod.weekly);

/// Resumo memoizado — recalcula só quando tarefas, hábitos, sessões,
/// período ou o dia mudam.
///
/// Estatísticas é uma feature **agregadora**: é a única (junto com a tela
/// Hoje) que pode ler dados de outras features. Ver
/// `docs/adr/0002-providers-em-core.md`.
final statsSummaryProvider = Provider<StatsSummary>((ref) {
  return StatsCalculator.summarize(
    tasks: ref.watch(tasksProvider),
    habits: ref.watch(habitsProvider),
    sessions: ref.watch(pomodoroHistoryProvider),
    period: ref.watch(statsPeriodProvider),
    today: ref.watch(todayProvider),
  );
});
