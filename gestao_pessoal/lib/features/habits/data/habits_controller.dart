import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/prefs_store.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/json_coders.dart';
import '../../settings/data/settings_controller.dart';
import '../domain/habit_model.dart';

/// Provider do [PrefsStore] injetado pelo `main.dart`.
final prefsStoreProvider = Provider<PrefsStore>((ref) {
  throw UnimplementedError('PrefsStore must be overridden in main()');
});

/// Provider do [HapticsService] que respeita a flag `hapticsEnabled`
/// das configurações — quando o usuário desativa vibração, todas as
/// chamadas se tornam no-op.
final hapticsServiceProvider = Provider<HapticsService>((ref) {
  return HapticsService(enabled: ref.watch(settingsProvider).hapticsEnabled);
});

/// Provider do [SoundService] que respeita a flag `soundEnabled`
/// das configurações.
final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService(enabled: ref.watch(settingsProvider).soundEnabled);
});

const _uuid = Uuid();

/// Notifier que mantém a lista de hábitos do usuário em memória e
/// persiste cada mudança no `SharedPreferences` (RF-HB-01..05).
class HabitsNotifier extends Notifier<List<HabitModel>> {
  @override
  List<HabitModel> build() {
    final store = ref.watch(prefsStoreProvider);
    return JsonCoders.decodeList<HabitModel>(
      store.habits,
      HabitModel.fromJson,
    );
  }

  Future<void> _persist() async {
    final store = ref.read(prefsStoreProvider);
    final raw = JsonCoders.encodeList<HabitModel>(state, (h) => h.toJson());
    await store.setHabits(raw);
  }

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
    final updatedDates = [...habit.completedDates];
    if (isCompleted) {
      updatedDates.removeWhere(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day,
      );
    } else {
      updatedDates.add(DateTime(day.year, day.month, day.day));
    }

    final newStreak = DateFormatters.currentStreak(updatedDates, reference: day);
    final updated = habit.copyWith(
      completedDates: updatedDates,
      streakCount: newStreak,
    );
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
      streakCount: 0,
      reminderTime: reminderTime,
      durationMinutes: durationMinutes,
    );
    await add(habit);
    return habit;
  }
}

final habitsProvider =
    NotifierProvider<HabitsNotifier, List<HabitModel>>(HabitsNotifier.new);

/// Lista filtrada pelos hábitos previstos para o dia selecionado.
final habitsForDayProvider = Provider.family<List<HabitModel>, DateTime>(
  (ref, day) {
    final all = ref.watch(habitsProvider);
    return all.where((h) => h.isScheduledFor(day)).toList();
  },
);
