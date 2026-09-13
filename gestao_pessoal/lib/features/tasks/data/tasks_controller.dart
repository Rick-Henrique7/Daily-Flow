import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/json_coders.dart';
import '../domain/subtask_model.dart';
import '../domain/task_model.dart';
import '../../habits/data/habits_controller.dart';

const _uuid = Uuid();

class TasksNotifier extends Notifier<List<TaskModel>> {
  @override
  List<TaskModel> build() {
    final store = ref.watch(prefsStoreProvider);
    return JsonCoders.decodeList<TaskModel>(store.tasks, TaskModel.fromJson)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  Future<void> _persist() async {
    final store = ref.read(prefsStoreProvider);
    final raw = JsonCoders.encodeList<TaskModel>(state, (t) => t.toJson());
    await store.setTasks(raw);
  }

  Future<TaskModel> create({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    String category = 'Geral',
    DateTime? dueDate,
  }) async {
    final maxOrder = state.isEmpty
        ? 0
        : state.map((t) => t.orderIndex).reduce((a, b) => a > b ? a : b);
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      category: category,
      dueDate: dueDate,
      isCompleted: false,
      completedAt: null,
      subtasks: const [],
      orderIndex: maxOrder + 1,
    );
    state = [...state, task];
    await _persist();
    return task;
  }

  Future<void> update(TaskModel task) async {
    state = [
      for (final t in state) if (t.id == task.id) task else t,
    ];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((t) => t.id != id).toList();
    await _persist();
  }

  Future<void> toggleCompleted(TaskModel task) async {
    final newCompleted = !task.isCompleted;
    final updated = task.copyWith(
      isCompleted: newCompleted,
      completedAt: newCompleted ? DateTime.now() : null,
      clearCompletedAt: !newCompleted,
    );
    await update(updated);
    await ref.read(hapticsServiceProvider).light();
  }

  /// Sub-tarefas (RF-TD-01).
  Future<void> addSubtask(String taskId, String title) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final updated = task.copyWith(
      subtasks: [
        ...task.subtasks,
        SubtaskModel(
          id: _uuid.v4(),
          title: title,
          isCompleted: false,
        ),
      ],
    );
    await update(updated);
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final updated = task.copyWith(
      subtasks: [
        for (final s in task.subtasks)
          if (s.id == subtaskId) s.copyWith(isCompleted: !s.isCompleted) else s,
      ],
    );
    await update(updated);
  }

  /// Reordena a lista (Drag & Drop — RF-TD-02).
  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [...state];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    state = [
      for (var i = 0; i < list.length; i++)
        list[i].copyWith(orderIndex: i),
    ];
    await _persist();
  }
}

final tasksProvider =
    NotifierProvider<TasksNotifier, List<TaskModel>>(TasksNotifier.new);

/// Filtros para a tela To-Do.
enum TaskFilter { all, today, upcoming, completed }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

/// Lista filtrada derivada do filtro ativo.
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final tasks = ref.watch(tasksProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  switch (filter) {
    case TaskFilter.all:
      return tasks;
    case TaskFilter.today:
      return tasks.where((t) {
        if (t.dueDate == null) return false;
        final due = t.dueDate!;
        return due.year == today.year &&
            due.month == today.month &&
            due.day == today.day;
      }).toList();
    case TaskFilter.upcoming:
      return tasks.where((t) {
        if (t.dueDate == null) return false;
        return t.dueDate!.isAfter(today) && !t.isCompleted;
      }).toList();
    case TaskFilter.completed:
      return tasks.where((t) => t.isCompleted).toList();
  }
});
