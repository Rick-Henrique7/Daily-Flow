import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/glass_input_field.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../data/habits_controller.dart';
import '../domain/habit_model.dart';
import '../../settings/data/settings_controller.dart';

/// Provider local do dia selecionado no calendário.
final _selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Formata uma estimativa em minutos para o cartão de hábito.
String _cardDurationLabel(int minutes) {
  if (minutes < 60) return '${minutes}min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return '${h}h';
  return '${h}h${m.toString().padLeft(2, '0')}';
}

/// Itera os últimos 90 dias (incluindo hoje) e retorna um set de
/// dias em que pelo menos um hábito previsto (que contenha o
/// `weekday` em `frequencyDays`) não foi concluído. Dias futuros são
/// ignorados — não fazem sentido.
Set<DateTime> _buildIncompleteDaySet(List<HabitModel> habits) {
  if (habits.isEmpty) return <DateTime>{};
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final result = <DateTime>{};
  for (int i = 0; i <= 90; i++) {
    final day = today.subtract(Duration(days: i));
    final weekday = day.weekday;

    for (final habit in habits) {
      if (habit.frequencyDays.contains(weekday) &&
          !habit.isCompletedOn(day)) {
        result.add(day);
        break;
      }
    }
  }
  return result;
}

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(_selectedDayProvider);
    final habits = ref.watch(habitsForDayProvider(selectedDay));
    final allHabits = ref.watch(habitsProvider);
    final accent = ref.watch(accentColorProvider);
    final accentDim = HSVColor.fromColor(accent).withValue(0.7).toColor();

    // Appointments por dia (syncfusion exige DateTime por evento).
    final appointments = <Appointment>[];
    for (final habit in allHabits) {
      for (final date in habit.completedDates) {
        appointments.add(Appointment(
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          subject: habit.title,
          color: habit.color,
          id: '${habit.id}-${date.toIso8601String()}',
        ));
      }
    }

    // Dias com pelo menos 1 hábito previsto **não** concluído
    // (passados + hoje). O calendário pinta esses dias em vermelho via
    // `monthCellBuilder`.
    final incompleteDays = _buildIncompleteDaySet(allHabits);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Hábitos'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 180),
        children: [
          // Calendário Syncfusion (re-paint isolado do resto)
          RepaintBoundary(
            child: _SfCalendarCard(
              selectedDay: selectedDay,
              appointments: appointments,
              incompleteDays: incompleteDays,
              accent: accent,
              onDaySelected: (day) =>
                  ref.read(_selectedDayProvider.notifier).state = day,
            ),
          ),
          const SizedBox(height: 16),

          // Streak Card
          RepaintBoundary(
            child: LiquidGlassCard(
              gradient: LinearGradient(
                colors: [accent, accentDim],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: AppColors.textPrimary, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Maior Streak',
                        style:
                            TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        allHabits.isEmpty
                            ? '0 dias'
                            : '${allHabits.map((h) => h.streakCount).reduce((a, b) => a > b ? a : b)} dias',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 16),

          // Header da lista
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${DateFormatters.weekdayShort(selectedDay).toUpperCase()}, ${selectedDay.day}/${selectedDay.month}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${habits.length} hábito${habits.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista de hábitos do dia
          if (habits.isEmpty)
            const LiquidGlassCard(
              child: Text(
                'Nenhum hábito previsto para este dia. Crie um pelo botão +.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...habits.map(
              (habit) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey('habit-${habit.id}'),
                  direction: DismissDirection.endToStart,
                  background: _DeleteBackground(),
                  confirmDismiss: (_) => _confirmDelete(context, habit.title),
                  onDismissed: (_) => _onHabitDismissed(context, ref, habit),
                  child: _HabitCard(
                    habit: habit,
                    day: selectedDay,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateHabitDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openHabitDialog(
      BuildContext context, WidgetRef ref, HabitModel? existing) async {
    await showDialog<void>(
      context: context,
      builder: (_) => CreateHabitDialog(existing: existing),
    );
  }

  /// Compat — abre dialog de criação (chamado pelo + do AppBar e FAB).
  Future<void> _showCreateHabitDialog(
      BuildContext context, WidgetRef ref) async {
    await _openHabitDialog(context, ref, null);
  }

  /// Diálogo de confirmação antes de excluir um hábito (RF-HB-08).
  ///
  /// Retorna `true` se o usuário confirmou, `false` se cancelou, e `null`
  /// se o diálogo foi dispensado por outro meio (ex: tap fora).
  Future<bool?> _confirmDelete(BuildContext context, String habitTitle) {
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
                    'Excluir hábito?',
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
                '"$habitTitle" e todo o seu histórico de conclusões serão removidos. Essa ação pode ser desfeita na barra inferior.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
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

  /// Remove o hábito e oferece "Desfazer" por 4 segundos na snackbar.
  Future<void> _onHabitDismissed(
      BuildContext context, WidgetRef ref, HabitModel habit) async {
    await ref.read(habitsProvider.notifier).remove(habit.id);
    if (!context.mounted) return;
    AppUndoSnackBar.show(
      context,
      ref,
      icon: Icons.delete_outline,
      message: 'Hábito "${habit.title}" excluído',
      onUndo: () => ref.read(habitsProvider.notifier).add(habit),
    );
  }
}

/// Fundo vermelho revelado ao deslizar o cartão para a esquerda
/// (delete). Posiciona o ícone de lixeira à direita.
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

class _SfCalendarCard extends StatelessWidget {
  const _SfCalendarCard({
    required this.selectedDay,
    required this.appointments,
    required this.incompleteDays,
    required this.accent,
    required this.onDaySelected,
  });
  final DateTime selectedDay;
  final List<Appointment> appointments;
  final Set<DateTime> incompleteDays;
  final Color accent;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return LiquidGlassCard(
      padding: const EdgeInsets.all(8),
      child: SfCalendar(
        view: CalendarView.month,
        backgroundColor: Colors.transparent,
        selectionDecoration: BoxDecoration(
          color: accent.withValues(alpha: 0.25),
          border: Border.all(color: accent, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        todayHighlightColor: accent,
        todayTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        monthViewSettings: const MonthViewSettings(
          monthCellStyle: MonthCellStyle(
            textStyle: TextStyle(color: AppColors.textPrimary),
            trailingDatesTextStyle: TextStyle(color: AppColors.textTertiary),
            leadingDatesTextStyle: TextStyle(color: AppColors.textTertiary),
          ),
          navigationDirection: MonthNavigationDirection.horizontal,
        ),
        headerStyle: const CalendarHeaderStyle(
          textStyle: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          backgroundColor: Colors.transparent,
        ),
        viewHeaderStyle: const ViewHeaderStyle(
          dayTextStyle: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          dateTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          backgroundColor: Colors.transparent,
        ),
        initialSelectedDate: selectedDay,
        initialDisplayDate: selectedDay,
        dataSource: _HabitDataSource(appointments),
        // Dias com hábito(s) previsto(s) **não** concluído(s) ficam
        // destacados em vermelho. Mantemos o número do dia + os
        // indicadores de appointment do Syncfusion.
        monthCellBuilder: (context, details) {
          final date = details.date;
          final isIncomplete = incompleteDays.contains(
            DateTime(date.year, date.month, date.day),
          );
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
          final appts = details.appointments.cast<Appointment>();

          return Stack(
            fit: StackFit.expand,
            children: [
              // Fundo muted para dias incompletos (design system: sem
              // red/orange p/ estados negativos, usar surface-2).
              if (isIncomplete)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textTertiary,
                      width: 1,
                    ),
                  ),
                ),
              // Número do dia (texto secundário se incompleto)
              Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isIncomplete
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontWeight:
                        isToday ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              // Pontos de appointment (até 3 visíveis) — só pra dias
              // com conclusões registradas
              if (appts.isNotEmpty)
                Positioned(
                  bottom: 3,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final a in appts.take(3))
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: a.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
        onSelectionChanged: (details) {
          if (details.date != null) onDaySelected(details.date!);
        },
        cellBorderColor: Colors.transparent,
        showNavigationArrow: true,
      ),
    );
  }
}

class _HabitDataSource extends CalendarDataSource {
  _HabitDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].startTime;

  @override
  DateTime getEndTime(int index) => appointments![index].endTime;

  @override
  String getSubject(int index) => appointments![index].subject;

  @override
  Color getColor(int index) => appointments![index].color;
}

class _HabitCard extends ConsumerWidget {
  const _HabitCard({required this.habit, required this.day});
  final HabitModel habit;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = habit.isCompletedOn(day);
    final accent = ref.watch(accentColorProvider);
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        onTap: () {
          // Tap em qualquer parte do card abre o dialog de edição
          // (mesmo padrão da tela de Tarefas).
          showDialog<void>(
            context: context,
            builder: (_) => CreateHabitDialog(existing: habit),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: habit.color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(habit.icon, color: habit.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Meta: ${habit.targetValue} ${habit.unit} • ${habit.category}'
                      '${habit.durationMinutes != null ? ' • ${_cardDurationLabel(habit.durationMinutes!)}' : ''}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: done ? 'Reabrir' : 'Concluir',
                icon: Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: done ? accent : AppColors.textTertiary,
                ),
                onPressed: () {
                  ref
                      .read(habitsProvider.notifier)
                      .toggleCompletionForDate(habit, day);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo completo de criação OU edição de hábito.
///
/// Quando [existing] é `null` é criação; quando é uma [HabitModel] é
/// edição (campos pré-preenchidos) e o botão primário diz "Salvar".
///
/// Inclui nome, categoria, grade de ícones, paleta de cores,
/// frequência (dias da semana), lembrete e estimativa de duração.
class CreateHabitDialog extends ConsumerStatefulWidget {
  const CreateHabitDialog({super.key, this.existing});

  /// Se não-nulo, abre no modo edição com os campos preenchidos.
  final HabitModel? existing;

  bool get isEditing => existing != null;

  @override
  ConsumerState<CreateHabitDialog> createState() => _CreateHabitDialogState();
}

class _CreateHabitDialogState extends ConsumerState<CreateHabitDialog> {
  // Controllers com identidade única — NUNCA reaproveitar entre dois
  // TextField (compartilham estado e a digitação vaza).
  late final TextEditingController _titleCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _unitCtrl;

  late String _iconKey;
  late String _colorHex;
  TimeOfDay? _reminder;
  int? _durationMinutes;
  late final Set<int> _frequency;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _categoryCtrl = TextEditingController(text: e?.category ?? '');
    _targetCtrl = TextEditingController(text: '${e?.targetValue ?? 1}');
    _unitCtrl = TextEditingController(text: e?.unit ?? 'vez');
    _iconKey = e?.iconKey ?? 'water';
    _colorHex = e?.colorHex ?? '#06B6D4';
    _reminder = e?.reminderTime;
    _durationMinutes = e?.durationMinutes;
    _frequency = {...?e?.frequencyDays};
  }

  static const _palette = [
    '#8B5CF6', // Roxo
    '#06B6D4', // Ciano
    '#34D399', // Verde
    '#FBBF24', // Amarelo
    '#F43F5E', // Rosa
    '#FB7185', // Rosa claro
    '#818CF8', // Índigo
    '#A78BFA', // Lilás
  ];

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _targetCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickReminder() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminder ?? const TimeOfDay(hour: 7, minute: 0),
    );
    if (picked != null) setState(() => _reminder = picked);
  }

  /// Abre um picker com durações pré-definidas + opção "Sem estimativa".
  Future<void> _pickDuration() async {
    final picked = await showDialog<int?>(
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
              const Text(
                'Estimativa de duração',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Quanto tempo você pretende dedicar a este hábito?',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mins in const [5, 10, 15, 20, 30, 45, 60, 90])
                    _DurationChip(
                      label: _formatDuration(mins),
                      active: _durationMinutes == mins,
                      onTap: () => Navigator.pop(ctx, mins),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, -1), // limpar
                    child: const Text('Sem estimativa'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, _durationMinutes),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _durationMinutes = picked < 0 ? null : picked);
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h${m.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    final notifier = ref.read(habitsProvider.notifier);
    final category = _categoryCtrl.text.trim().isEmpty
        ? 'Geral'
        : _categoryCtrl.text.trim();
    final unit = _unitCtrl.text.trim().isEmpty
        ? 'vez'
        : _unitCtrl.text.trim();

    if (widget.isEditing) {
      final updated = widget.existing!.copyWith(
        title: _titleCtrl.text.trim(),
        category: category,
        iconKey: _iconKey,
        colorHex: _colorHex,
        frequencyDays: _frequency.toList()..sort(),
        targetValue: int.tryParse(_targetCtrl.text) ?? 1,
        unit: unit,
        reminderTime: _reminder,
        clearReminderTime: _reminder == null,
        durationMinutes: _durationMinutes,
        clearDurationMinutes: _durationMinutes == null,
      );
      await notifier.update(updated);
    } else {
      await notifier.create(
        title: _titleCtrl.text.trim(),
        category: category,
        iconKey: _iconKey,
        colorHex: _colorHex,
        frequencyDays: _frequency.toList()..sort(),
        targetValue: int.tryParse(_targetCtrl.text) ?? 1,
        unit: unit,
        reminderTime: _reminder,
        durationMinutes: _durationMinutes,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  /// Confirma a exclusão do hábito a partir do diálogo de edição.
  ///
  /// Mesmo padrão Liquid Glass do `_confirmDelete` da lista: pergunta,
  /// remove, fecha o diálogo de edição e oferece "Desfazer" via snackbar.
  /// Sem isso, um hábito só podia ser excluído deslizando o card — quem
  /// clica pra editar não tem caminho de saída.
  Future<void> _confirmAndDelete() async {
    final habit = widget.existing;
    if (habit == null) return;

    final confirmed = await showDialog<bool>(
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
                    'Excluir hábito?',
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
                '"${habit.title}" e todo o seu histórico de conclusões '
                'serão removidos. Essa ação pode ser desfeita na barra '
                'inferior.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
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

    if (confirmed != true) return;
    if (!mounted) return;

    // Captura as dependências ANTES de fechar o diálogo — depois do pop
    // o `context` da árvore do diálogo já não tem Scaffold ancestral.
    final notifier = ref.read(habitsProvider.notifier);
    final habitSnapshot = habit;
    final outerContext = context; // contexto da árvore raiz (com Scaffold)

    // Fecha o diálogo de edição.
    Navigator.pop(context);

    await notifier.remove(habitSnapshot.id);

    if (!outerContext.mounted) return;
    AppUndoSnackBar.show(
      outerContext,
      ref,
      icon: Icons.delete_outline,
      message: 'Hábito "${habitSnapshot.title}" excluído',
      onUndo: () => notifier.add(habitSnapshot),
    );
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
                widget.isEditing ? 'Editar Hábito' : 'Novo Hábito',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Nome
              GlassInputField(
                controller: _titleCtrl,
                hintText: 'Nome — Ex.: Beber 2L de Água',
              ),
              const SizedBox(height: 12),
              GlassInputField(
                controller: _categoryCtrl,
                hintText: 'Categoria',
              ),
              const SizedBox(height: 16),

              // Ícones (grid)
              const Text(
                'Ícone',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in HabitIcons.all.entries)
                    GestureDetector(
                      onTap: () => setState(() => _iconKey = entry.key),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _iconKey == entry.key
                              ? _hexToColor(_colorHex).withValues(alpha: 0.35)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _iconKey == entry.key
                                ? _hexToColor(_colorHex)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(entry.value,
                            color: _iconKey == entry.key
                                ? _hexToColor(_colorHex)
                                : AppColors.textPrimary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Paleta de cores
              const Text(
                'Cor',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final hex in _palette)
                    GestureDetector(
                      onTap: () => setState(() => _colorHex = hex),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _hexToColor(hex),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _colorHex == hex
                                ? AppColors.textPrimary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Meta + Unidade
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GlassInputField(
                      controller: _targetCtrl,
                      hintText: 'Meta',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GlassInputField(
                      controller: _unitCtrl,
                      hintText: 'Unidade (ml, min...)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Estimativa de duração
              const Text(
                'Estimativa',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickDuration,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: _durationMinutes == null
                        ? Colors.white.withValues(alpha: 0.08)
                        : accent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _durationMinutes == null
                          ? Colors.white.withValues(alpha: 0.15)
                          : accent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: _durationMinutes == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _durationMinutes == null
                              ? 'Tempo estimado (ex: 30 min)'
                              : 'Estimado: ${_formatDuration(_durationMinutes!)}',
                          style: TextStyle(
                            color: _durationMinutes == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_durationMinutes != null)
                        GestureDetector(
                          onTap: () =>
                              setState(() => _durationMinutes = null),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Frequência
              const Text(
                'Frequência',
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
                      label: _dayLabel(i),
                      active: _frequency.contains(i),
                      onTap: () => setState(() {
                        if (_frequency.contains(i)) {
                          _frequency.remove(i);
                        } else {
                          _frequency.add(i);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Lembrete
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary),
                title: Text(
                  _reminder == null
                      ? 'Sem lembrete'
                      : 'Lembrete às ${_reminder!.format(context)}',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                trailing: TextButton(
                  onPressed: _pickReminder,
                  child: Text(_reminder == null ? 'Definir' : 'Alterar'),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Excluir só aparece quando estamos editando um hábito
                  // existente. Sem isso, o usuário não tem como remover
                  // o hábito a partir do diálogo — só deslizando o card.
                  if (widget.isEditing) ...[
                    TextButton.icon(
                      onPressed: _confirmAndDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                      label: const Text(
                        'Excluir',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.surface2,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppColors.radiusSm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
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

  String _dayLabel(int weekday) {
    const labels = ['', 'S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return labels[weekday];
  }
}

class _DayChip extends ConsumerWidget {
  const _DayChip({required this.label, required this.active, required this.onTap});
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
        duration: const Duration(milliseconds: 200),
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
          color: active ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Chip de duração para o picker de estimativa (5min, 10min, 1h...).
class _DurationChip extends ConsumerWidget {
  const _DurationChip({
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  colors: [accent, HSVColor.fromColor(accent).withValue(0.7).toColor()],
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
