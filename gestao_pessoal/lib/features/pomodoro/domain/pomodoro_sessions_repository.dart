import 'pomodoro_session_model.dart';

/// Contrato de persistência do histórico de sessões de foco.
abstract interface class PomodoroSessionsRepository {
  List<PomodoroSessionModel> loadAll();
  Future<void> saveAll(List<PomodoroSessionModel> sessions);
}
