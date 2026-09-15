import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/sound_service.dart';
import '../../../core/utils/json_coders.dart';
import '../../habits/data/habits_controller.dart';
import '../../settings/data/settings_controller.dart';
import '../domain/subtask_model.dart';
import '../domain/task_model.dart';

/// Provider do [SoundService] que respeita a flag `soundEnabled`
/// das configurações — quando desativado, todas as chamadas viram no-op.
final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService(enabled: ref.watch(settingsProvider).soundEnabled);
});

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
    TimeOfDay? dueTime,
    List<int> repeatDays = const [],
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
      dueTime: dueTime,
      repeatDays: repeatDays,
      isCompleted: false,
      completedAt: null,
      subtasks: const [],
      orderIndex: maxOrder + 1,
    );
    state = [...state, task];
    await _persist();
    return task;
  }

  /// Re-insere uma tarefa existente (mesmo ID). Usado pelo "Desfazer"
  /// após swipe-to-delete — preserva o id original e o `orderIndex`.
  Future<void> add(TaskModel task) async {
    state = [...state, task];
    await _persist();
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
    // Som de sucesso só ao CONCLUIR (não ao reabrir)
    if (newCompleted) {
      await ref.read(soundServiceProvider).playSuccess();
    }
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
///
/// Regras por aba (RF-TD-04):
/// - **Todas**           → todas as tarefas, ordenadas por data/hora.
/// - **Hoje**             → tarefas pendentes com `dueDate == hoje` OU
///                          recorrentes cujo `weekday` bate. Exclui
///                          concluídas.
/// - **Próximas**         → pendentes que NÃO estão em "Hoje": futuras,
///                          atrasadas e recorrentes sem data. Ordenadas
///                          por data crescente (atrasadas primeiro).
/// - **Concluídas**       → todas as concluídas, mais recentes primeiro.
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final tasks = ref.watch(tasksProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  switch (filter) {
    case TaskFilter.all:
      return [...tasks]..sort(_compareBySchedule);

    case TaskFilter.today:
      return tasks
          .where((t) => !t.isCompleted && _isScheduledFor(t, today))
          .toList()
        ..sort((a, b) {
          final cmp = _compareBySchedule(a, b);
          if (cmp != 0) return cmp;
          return _dueMinutesOf(a).compareTo(_dueMinutesOf(b));
        });

    case TaskFilter.upcoming:
      return tasks
          .where((t) => !t.isCompleted && !_isScheduledFor(t, today))
          .toList()
        ..sort(_compareBySchedule);

    case TaskFilter.completed:
      return tasks.where((t) => t.isCompleted).toList()
        ..sort((a, b) {
          final ad = a.completedAt;
          final bd = b.completedAt;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad); // mais recente primeiro
        });
  }
});

/// Verifica se a tarefa deve aparecer em "Hoje" no dia [today].
bool _isScheduledFor(TaskModel t, DateTime today) {
  // 1) Pontual com data == hoje
  final due = t.dueDate;
  if (due != null) {
    if (due.year == today.year &&
        due.month == today.month &&
        due.day == today.day) {
      return true;
    }
  }
  // 2) Recorrente em que o dia da semana bate
  if (t.repeatDays.isNotEmpty && t.repeatDays.contains(today.weekday)) {
    return true;
  }
  return false;
}

/// Minutos do dia da `dueTime` (00:00 → 0). Retorna -1 se sem hora.
int _dueMinutesOf(TaskModel t) {
  final time = t.dueTime;
  if (time == null) return -1;
  return time.hour * 60 + time.minute;
}

/// Compara tarefas por data (asc) + hora (asc). Sem data vai pro final.
int _compareBySchedule(TaskModel a, TaskModel b) {
  final ad = a.dueDate;
  final bd = b.dueDate;
  if (ad == null && bd == null) {
    return _dueMinutesOf(a).compareTo(_dueMinutesOf(b));
  }
  if (ad == null) return 1;
  if (bd == null) return -1;
  final cmp = ad.compareTo(bd);
  if (cmp != 0) return cmp;
  return _dueMinutesOf(a).compareTo(_dueMinutesOf(b));
}
