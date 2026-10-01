import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/prefs_store.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/json_coders.dart';
import '../domain/task_model.dart';
import '../domain/tasks_repository.dart';

/// [TasksRepository] sobre `SharedPreferences`.
class PrefsTasksRepository implements TasksRepository {
  PrefsTasksRepository(this._store);

  final PrefsStore _store;

  @override
  List<TaskModel> loadAll() =>
      JsonCoders.decodeList<TaskModel>(_store.tasks, TaskModel.fromJson);

  @override
  Future<void> saveAll(List<TaskModel> tasks) => _store.setTasks(
        JsonCoders.encodeList<TaskModel>(tasks, (t) => t.toJson()),
      );
}

final tasksRepositoryProvider = Provider<TasksRepository>(
  (ref) => PrefsTasksRepository(ref.watch(prefsStoreProvider)),
);
