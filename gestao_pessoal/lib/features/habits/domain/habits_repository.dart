import 'habit_model.dart';

/// Contrato de persistência de hábitos.
///
/// O domínio define *o que* precisa ser guardado; a camada `data/`
/// decide *como* (hoje SharedPreferences, amanhã Isar/SQLite/nuvem) sem
/// que controllers ou telas mudem. Ver `docs/adr/0003-repositorios.md`.
abstract interface class HabitsRepository {
  /// Carrega todos os hábitos. Síncrono porque o armazenamento já está
  /// em memória depois do `PrefsStore.open()` no `main.dart`.
  List<HabitModel> loadAll();

  /// Persiste a lista completa.
  Future<void> saveAll(List<HabitModel> habits);
}
