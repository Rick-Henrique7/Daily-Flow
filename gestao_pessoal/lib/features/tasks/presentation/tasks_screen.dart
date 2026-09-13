import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_input_field.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../data/tasks_controller.dart';
import '../domain/subtask_model.dart';
import '../domain/task_model.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    final tasks = ref.watch(filteredTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final f in TaskFilter.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_label(f)),
                      selected: filter == f,
                      onSelected: (_) =>
                          ref.read(taskFilterProvider.notifier).state = f,
                      selectedColor: AppColors.purpleFluidStart,
                      labelStyle: TextStyle(
                        color: filter == f
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma tarefa neste filtro.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              itemCount: tasks.length,
              onReorder: (oldI, newI) =>
                  ref.read(tasksProvider.notifier).reorder(oldI, newI),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  key: ValueKey(task.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TaskTile(task: task),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _label(TaskFilter f) => switch (f) {
        TaskFilter.all => 'Todas',
        TaskFilter.today => 'Hoje',
        TaskFilter.upcoming => 'Próximas',
        TaskFilter.completed => 'Concluídas',
      };

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    String category = 'Geral';

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: LiquidGlassCard(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nova Tarefa',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassInputField(
                    controller: titleCtrl,
                    hintText: 'Título',
                  ),
                  const SizedBox(height: 12),
                  // Container vítreo ao redor do dropdown pra combinar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField<TaskPriority>(
                      initialValue: priority,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceElevated,
                      decoration: const InputDecoration(
                        hintText: 'Prioridade',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      iconEnabledColor: AppColors.textPrimary,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      items: [
                        for (final p in TaskPriority.values)
                          DropdownMenuItem(
                            value: p,
                            child: Row(
                              children: [
                                Icon(p.icon, color: p.color, size: 18),
                                const SizedBox(width: 8),
                                Text(p.label),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (v) =>
                          setState(() => priority = v ?? priority),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassInputField(
                    controller: titleCtrl,
                    hintText: 'Categoria',
                    onChanged: (v) => category = v,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          if (titleCtrl.text.trim().isEmpty) return;
                          await ref.read(tasksProvider.notifier).create(
                                title: titleCtrl.text.trim(),
                                priority: priority,
                                category: category,
                              );
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: const Text('Criar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: task.priority.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.isCompleted
                      ? AppColors.success
                      : AppColors.textTertiary,
                ),
                onPressed: () =>
                    ref.read(tasksProvider.notifier).toggleCompleted(task),
              ),
            ],
          ),
          if (task.subtasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16),
              child: Text(
                'Sub-tarefas: ${task.completedSubtasksCount}/${task.subtasks.length}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
