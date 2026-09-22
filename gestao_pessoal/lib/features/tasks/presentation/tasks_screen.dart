import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/glass_input_field.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../data/tasks_controller.dart';
import '../../settings/data/settings_controller.dart';
import '../domain/subtask_model.dart';
import '../domain/task_model.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    final tasks = ref.watch(filteredTasksProvider);
    final accent = ref.watch(accentColorProvider);

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
                      selectedColor: accent,
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
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _emptyIconFor(filter),
                      size: 56,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _emptyTitleFor(filter),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _emptyHintFor(filter),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (filter == TaskFilter.all ||
                        filter == TaskFilter.today) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _openTaskDialog(context, null),
                        icon: const Icon(Icons.add),
                        label: const Text('Criar tarefa'),
                      ),
                    ],
                  ],
                ),
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
                  key: ValueKey('task-row-${task.id}'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey('task-dismiss-${task.id}'),
                    direction: DismissDirection.endToStart,
                    background: const _DeleteBackground(),
                    confirmDismiss: (_) =>
                        _confirmDelete(context, ref, task),
                    onDismissed: (_) =>
                        _onTaskDismissed(context, ref, task),
                    child: _TaskTile(
                      task: task,
                      onTap: () => _openTaskDialog(context, task),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskDialog(context, null),
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

  IconData _emptyIconFor(TaskFilter f) => switch (f) {
        TaskFilter.all => Icons.checklist_outlined,
        TaskFilter.today => Icons.wb_sunny_outlined,
        TaskFilter.upcoming => Icons.upcoming_outlined,
        TaskFilter.completed => Icons.task_alt_outlined,
      };

  String _emptyTitleFor(TaskFilter f) => switch (f) {
        TaskFilter.all => 'Nenhuma tarefa por aqui',
        TaskFilter.today => 'Nada pendente para hoje',
        TaskFilter.upcoming => 'Sem tarefas futuras',
        TaskFilter.completed => 'Nenhuma concluída ainda',
      };

  String _emptyHintFor(TaskFilter f) => switch (f) {
        TaskFilter.all => 'Toque no + para criar a primeira.',
        TaskFilter.today =>
          'Tarefas com data, hora ou repetição para hoje aparecem aqui.',
        TaskFilter.upcoming =>
          'Tarefas atrasadas, futuras e recorrentes aparecem aqui.',
        TaskFilter.completed =>
          'Quando você marcar tarefas como concluídas, elas aparecem aqui.',
      };

  /// Abre o dialog no modo edição (se [existing] for não-nulo) ou criação.
  Future<void> _openTaskDialog(
      BuildContext context, TaskModel? existing) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _TaskDialog(existing: existing),
    );
  }

  /// Confirmação Liquid Glass antes de excluir a tarefa.
///
/// Para tarefas recorrentes (com `repeatDays` ou `dueDate` no futuro),
/// avisa explicitamente que **todas as ocorrências futuras derivadas
/// desta tarefa também serão removidas** — porque uma `TaskModel`
/// recorrente representa toda a cadeia, não só uma instância.
  Future<bool?> _confirmDelete(BuildContext context, WidgetRef ref, TaskModel task) {
    final recurring = _isRecurring(task);
    final accent = ref.read(accentColorProvider);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: LiquidGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.delete_outline, color: AppColors.textPrimary),
                  SizedBox(width: 8),
                  Text(
                    'Excluir tarefa?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '"${task.title}" será removida permanentemente.'
                ' Essa ação pode ser desfeita na barra inferior.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (recurring) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(AppColors.radiusSm),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.repeat_rounded,
                          size: 18, color: accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _recurrenceWarning(task),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surface2,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Excluir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Detecta se a tarefa representa uma cadeia de ocorrências futuras.
  bool _isRecurring(TaskModel t) {
    if (t.repeatDays.isNotEmpty) return true;
    final due = t.dueDate;
    if (due == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return due.isAfter(today);
  }

  /// Texto do aviso exibido quando a tarefa é recorrente ou tem
  /// data futura — explica que excluir remove toda a cadeia.
  String _recurrenceWarning(TaskModel t) {
    if (t.repeatDays.isNotEmpty) {
      const labels = ['', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      final days = [...t.repeatDays]..sort();
      final list = days.map((d) => labels[d]).join(', ');
      return 'Esta tarefa se repete em $list. Excluir também remove '
          'todas as ocorrências futuras.';
    }
    return 'Esta tarefa tem data futura. Excluir também remove o '
        'agendamento pendente.';
  }

  /// Remove a tarefa e oferece "Desfazer" por 4s na snackbar.
  Future<void> _onTaskDismissed(
      BuildContext context, WidgetRef ref, TaskModel task) async {
    await ref.read(tasksProvider.notifier).remove(task.id);
    if (!context.mounted) return;
    final recurring = _isRecurring(task);
    AppUndoSnackBar.show(
      context,
      ref,
      icon: recurring ? Icons.event_repeat_outlined : Icons.delete_outline,
      message: recurring
          ? 'Tarefa "${task.title}" e suas próximas ocorrências foram excluídas'
          : 'Tarefa "${task.title}" excluída',
      onUndo: () => ref.read(tasksProvider.notifier).add(task),
    );
  }
}

/// Cartão de tarefa com tap para editar + check para concluir.
class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task, required this.onTap});
  final TaskModel task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueLine = _dueLine(task);
    final accent = ref.watch(accentColorProvider);
    // Mapeia prioridade para a cor — high usa accent (customizado),
    // medium usa accent escurecido, low fica muted gray.
    final Color priorityColor = switch (task.priority) {
      TaskPriority.high => accent,
      TaskPriority.medium => HSVColor.fromColor(accent).withValue(0.7).toColor(),
      TaskPriority.low => AppColors.textSecondary,
    };
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 32,
                    decoration: BoxDecoration(
                      color: priorityColor,
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
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
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
                          ? accent
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
        ),
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
    if (t.category.isNotEmpty) {
      parts.add(t.category);
    }
    return parts.isEmpty ? null : parts.join(' • ');
  }

  String _formatRepeat(List<int> days) {
    const labels = ['', 'S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final sorted = [...days]..sort();
    return sorted.map((d) => labels[d]).join(' ');
  }
}

/// Diálogo de criação OU edição de uma tarefa.
///
/// Quando [existing] é `null` é criação; quando é uma [TaskModel] é
/// edição e o botão primário diz "Salvar".
class _TaskDialog extends ConsumerStatefulWidget {
  const _TaskDialog({this.existing});
  final TaskModel? existing;

  bool get isEditing => existing != null;

  @override
  ConsumerState<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends ConsumerState<_TaskDialog> {
  // Controllers com keys explícitas para garantir identidade única.
  // Importante: NUNCA reaproveitar o mesmo controller em dois TextField
  // — eles compartilham estado e digitação num aparece no outro.
  late final TextEditingController _titleCtrl;
  late final TextEditingController _categoryCtrl;

  late TaskPriority _priority;
  // _dueDate default = HOJE (meia-noite) p/ que toda tarefa nova já
  // apareça em "Hoje" imediatamente. Mesmo se o usuário limpar com o
  // × (ficando sem data), a tarefa ainda entra em "Hoje" como ad-hoc
  // — ver `_isScheduledFor` no controller.
  late DateTime? _dueDate;
  TimeOfDay? _dueTime;
  late final Set<int> _repeatDays;

  static DateTime _todayMidnight() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _categoryCtrl = TextEditingController(text: e?.category ?? '');
    _priority = e?.priority ?? TaskPriority.medium;
    _dueDate = e?.dueDate ?? _todayMidnight();
    _dueTime = e?.dueTime;
    _repeatDays = {...?e?.repeatDays};
  }

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
      firstDate: DateTime(now.year - 1),
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
    final category = _categoryCtrl.text.trim();
    final notifier = ref.read(tasksProvider.notifier);

    if (widget.isEditing) {
      final updated = widget.existing!.copyWith(
        title: _titleCtrl.text.trim(),
        priority: _priority,
        category: category.isEmpty ? 'Geral' : category,
        dueDate: _dueDate,
        clearDueDate: _dueDate == null,
        dueTime: _dueTime,
        clearDueTime: _dueTime == null,
        repeatDays: _repeatDays.toList()..sort(),
      );
      await notifier.update(updated);
    } else {
      await notifier.create(
        title: _titleCtrl.text.trim(),
        priority: _priority,
        category: category.isEmpty ? 'Geral' : category,
        dueDate: _dueDate,
        dueTime: _dueTime,
        repeatDays: _repeatDays.toList()..sort(),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(accentColorProvider);
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
              Text(
                widget.isEditing ? 'Editar Tarefa' : 'Nova Tarefa',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Título
              GlassInputField(
                key: const ValueKey('task-title-field'),
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
                            Icon(p.icon, color: p.colorAt(accent), size: 18),
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

              // Categoria (controller separado do título)
              GlassInputField(
                key: const ValueKey('task-category-field'),
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
                      onClear: _dueDate == null
                          ? null
                          : () => setState(() => _dueDate = null),
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
                      onClear: _dueTime == null
                          ? null
                          : () => setState(() => _dueTime = null),
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
                    child: Text(widget.isEditing ? 'Salvar' : 'Criar'),
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
    final accent = ProviderScope.containerOf(context)
        .read(accentColorProvider);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? accent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? accent
                : Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  active ? AppColors.textPrimary : AppColors.textSecondary,
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
class _DayChip extends ConsumerWidget {
  const _DayChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    final accentDim = HSVColor.fromColor(accent).withValue(0.7).toColor();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  colors: [accent, accentDim],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
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

/// Fundo muted revelado ao deslizar a tarefa para a esquerda.
/// (Design system: "Don't use red/orange for negative states —
/// use muted gray instead".)
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.transparent, AppColors.surface2],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Excluir',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.delete_outline, color: AppColors.textPrimary, size: 22),
        ],
      ),
    );
  }
}