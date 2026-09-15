import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
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
    await showDialog<void>(
      context: context,
      builder: (_) => const _CreateTaskDialog(),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueLine = _dueLine(task);
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
                tooltip: task.isCompleted ? 'Reabrir' : 'Concluir',
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
          if (dueLine != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 16),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      dueLine,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
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

  String? _dueLine(TaskModel t) {
    final parts = <String>[];
    if (t.dueDate != null) {
      parts.add(DateFormatters.shortDate(t.dueDate!));
    }
    if (t.dueTime != null) {
      parts.add(
        '${t.dueTime!.hour.toString().padLeft(2, '0')}:${t.dueTime!.minute.toString().padLeft(2, '0')}',
      );
    }
    if (t.repeatDays.isNotEmpty) {
      parts.add('Repete: ${_formatRepeat(t.repeatDays)}');
    }
    return parts.isEmpty ? null : parts.join(' • ');
  }

  String _formatRepeat(List<int> days) {
    const labels = ['', 'S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final sorted = [...days]..sort();
    return sorted.map((d) => labels[d]).join(' ');
  }
}

/// Diálogo de criação de tarefa com data, hora e repetição semanal.
class _CreateTaskDialog extends ConsumerStatefulWidget {
  const _CreateTaskDialog();

  @override
  ConsumerState<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<_CreateTaskDialog> {
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController(text: 'Geral');

  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  final Set<int> _repeatDays = {};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  static const _dayLabels = ['', 'S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    await ref.read(tasksProvider.notifier).create(
          title: _titleCtrl.text.trim(),
          priority: _priority,
          category: _categoryCtrl.text.trim().isEmpty
              ? 'Geral'
              : _categoryCtrl.text.trim(),
          dueDate: _dueDate,
          dueTime: _dueTime,
          repeatDays: _repeatDays.toList()..sort(),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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

              // Título
              GlassInputField(
                controller: _titleCtrl,
                hintText: 'Título',
              ),
              const SizedBox(height: 12),

              // Prioridade
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
                  initialValue: _priority,
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
                      setState(() => _priority = v ?? _priority),
                ),
              ),
              const SizedBox(height: 12),

              // Categoria
              GlassInputField(
                controller: _categoryCtrl,
                hintText: 'Categoria',
              ),
              const SizedBox(height: 16),

              // Data + Hora
              const Text(
                'Quando',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _GlassPickerButton(
                      icon: Icons.event_outlined,
                      label: _dueDate == null
                          ? 'Data'
                          : DateFormatters.shortDate(_dueDate!),
                      active: _dueDate != null,
                      onTap: _pickDate,
                      onClear:
                          _dueDate == null ? null : () => setState(() => _dueDate = null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GlassPickerButton(
                      icon: Icons.schedule,
                      label: _dueTime == null
                          ? 'Hora'
                          : '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}',
                      active: _dueTime != null,
                      onTap: _pickTime,
                      onClear:
                          _dueTime == null ? null : () => setState(() => _dueTime = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Repetição (dias da semana)
              const Text(
                'Repetir',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 1; i <= 7; i++)
                    _DayChip(
                      label: _dayLabels[i],
                      active: _repeatDays.contains(i),
                      onTap: () => setState(() {
                        if (_repeatDays.contains(i)) {
                          _repeatDays.remove(i);
                        } else {
                          _repeatDays.add(i);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Ações
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Criar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão de seleção estilo Liquid Glass para data/hora.
class _GlassPickerButton extends StatelessWidget {
  const _GlassPickerButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? AppColors.purpleFluidStart.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? AppColors.purpleFluidStart
                : Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: active
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: active
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Chip de dia da semana (1=S … 7=D) usado para repetição.
class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: active ? AppColors.purpleFluid : null,
          color: active ? null : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}