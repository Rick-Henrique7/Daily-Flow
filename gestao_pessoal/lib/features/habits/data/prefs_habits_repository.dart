import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/prefs_store.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/json_coders.dart';
import '../domain/habit_model.dart';
import '../domain/habits_repository.dart';

/// [HabitsRepository] sobre `SharedPreferences` (JSON numa chave única).
class PrefsHabitsRepository implements HabitsRepository {
  PrefsHabitsRepository(this._store);

  final PrefsStore _store;

  @override
  List<HabitModel> loadAll() =>
      JsonCoders.decodeList<HabitModel>(_store.habits, HabitModel.fromJson);

  @override
  Future<void> saveAll(List<HabitModel> habits) => _store.setHabits(
        JsonCoders.encodeList<HabitModel>(habits, (h) => h.toJson()),
      );
}

/// Ponto de injeção: testes sobrescrevem com um repositório em memória.
final habitsRepositoryProvider = Provider<HabitsRepository>(
  (ref) => PrefsHabitsRepository(ref.watch(prefsStoreProvider)),
);
