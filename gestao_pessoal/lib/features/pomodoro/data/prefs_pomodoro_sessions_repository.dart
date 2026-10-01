import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/prefs_store.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/json_coders.dart';
import '../domain/pomodoro_session_model.dart';
import '../domain/pomodoro_sessions_repository.dart';

/// [PomodoroSessionsRepository] sobre `SharedPreferences`.
class PrefsPomodoroSessionsRepository implements PomodoroSessionsRepository {
  PrefsPomodoroSessionsRepository(this._store);

  final PrefsStore _store;

  @override
  List<PomodoroSessionModel> loadAll() =>
      JsonCoders.decodeList<PomodoroSessionModel>(
        _store.pomodoroSessions,
        PomodoroSessionModel.fromJson,
      );

  @override
  Future<void> saveAll(List<PomodoroSessionModel> sessions) =>
      _store.setPomodoroSessions(
        JsonCoders.encodeList<PomodoroSessionModel>(sessions, (s) => s.toJson()),
      );
}

final pomodoroSessionsRepositoryProvider =
    Provider<PomodoroSessionsRepository>(
  (ref) => PrefsPomodoroSessionsRepository(ref.watch(prefsStoreProvider)),
);
