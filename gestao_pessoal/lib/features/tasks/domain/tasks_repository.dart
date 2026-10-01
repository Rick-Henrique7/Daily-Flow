import 'task_model.dart';

/// Contrato de persistência de tarefas. Ver `HabitsRepository`.
abstract interface class TasksRepository {
  List<TaskModel> loadAll();
  Future<void> saveAll(List<TaskModel> tasks);
}
