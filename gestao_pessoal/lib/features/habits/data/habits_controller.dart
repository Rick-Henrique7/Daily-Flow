import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/utils/date_only.dart';
import '../domain/habit_model.dart';
import '../domain/habit_rules.dart';
import 'prefs_habits_repository.dart';

const _uuid = Uuid();

/// Notifier que mantém a lista de hábitos em memória e persiste cada
/// mudança pelo [HabitsRepository] (RF-HB-01..05). Não sabe *onde* os
/// dados ficam — só fala com a interface.
class HabitsNotifier extends Notifier<List<HabitModel>> {
  @override
  List<HabitModel> build() => ref.watch(habitsRepositoryProvider).loadAll();

  Future<void> _persist() => ref.read(habitsRepositoryProvider).saveAll(state);

  Future<void> add(HabitModel habit) async {
    state = [...state, habit];
    await _persist();
  }

  Future<void> update(HabitModel habit) async {
    state = [
      for (final h in state) if (h.id == habit.id) habit else h,
    ];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((h) => h.id != id).toList();
    await _persist();
  }

  /// Marca/Desmarca o hábito para o dia (RF-HB-02).
  Future<void> toggleCompletionForDate(HabitModel habit, DateTime day) async {
    final isCompleted = habit.isCompletedOn(day);
    final updatedDates = [
      for (final d in habit.completedDates)
        if (!isSameDay(d, day)) d,
      if (!isCompleted) dateOnly(day),
    ];
    final updated = habit.copyWith(completedDates: updatedDates);
    await update(updated);
    await ref.read(hapticsServiceProvider).light();
    // Som de sucesso só ao MARCAR (não ao desmarcar)
    if (!isCompleted) {
      await ref.read(soundServiceProvider).playSuccess();
    }
  }

  /// Cria um novo hábito com defaults seguros.
  Future<HabitModel> create({
    required String title,
    required String category,
    required String iconKey,
    required String colorHex,
    required List<int> frequencyDays,
    required int targetValue,
    required String unit,
    TimeOfDay? reminderTime,
    int? durationMinutes,
  }) async {
    final habit = HabitModel(
      id: _uuid.v4(),
      title: title,
      category: category,
      iconKey: iconKey,
      colorHex: colorHex,
      frequencyDays: frequencyDays,
      targetValue: targetValue,
      unit: unit,
      completedDates: const [],
      reminderTime: reminderTime,
      durationMinutes: durationMinutes,
    );
    await add(habit);
    return habit;
  }
}

final habitsProvider =
    NotifierProvider<HabitsNotifier, List<HabitModel>>(HabitsNotifier.new);

/// Hábitos previstos para o dia [day] (passe uma data **sem hora**).
///
/// `autoDispose`: antes a tela Hoje passava `DateTime.now()` (com
/// segundos) como chave — cada rebuild criava um provider novo que nunca
/// era descartado. Agora a chave é estável (`todayProvider`) e instâncias
/// sem uso são liberadas.
final habitsForDayProvider =
    Provider.autoDispose.family<List<HabitModel>, DateTime>((ref, day) {
  final all = ref.watch(habitsProvider);
  return all.where((h) => h.isScheduledFor(day)).toList();
});

/// Maior sequência atual entre os hábitos (calculada, nunca gravada).
final bestStreakProvider = Provider<int>((ref) {
  return HabitStreak.best(ref.watch(habitsProvider), ref.watch(todayProvider));
});

/// Dias dos últimos 90 com hábito previsto não concluído — memoizado:
/// só recalcula quando os hábitos ou o dia mudam (antes, a cada build).
final incompleteDaysProvider = Provider<Set<DateTime>>((ref) {
  return HabitCalendar.incompleteDays(
    ref.watch(habitsProvider),
    ref.watch(todayProvider),
  );
});
