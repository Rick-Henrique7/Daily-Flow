import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../data/habits_controller.dart';
import '../domain/habit_model.dart';

/// Provider local do dia selecionado no calendário.
final _selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(_selectedDayProvider);
    final habits = ref.watch(habitsForDayProvider(selectedDay));
    final allHabits = ref.watch(habitsProvider);

    // Appointments por dia (syncfusion exige DateTime por evento).
    final appointments = <CalendarAppointment>[];
    for (final habit in allHabits) {
      for (final date in habit.completedDates) {
        appointments.add(CalendarAppointment(
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          subject: habit.title,
          color: habit.color,
          id: '${habit.id}-${date.toIso8601String()}',
        ));
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Hábitos'),
        actions: [
          IconButton(
            tooltip: 'Adicionar',
            onPressed: () => _showCreateHabitDialog(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 180),
        children: [
          // Calendário Syncfusion
          _SfCalendarCard(
            selectedDay: selectedDay,
            appointments: appointments,
            onDaySelected: (day) =>
                ref.read(_selectedDayProvider.notifier).state = day,
          ),
          const SizedBox(height: 16),

          // Streak Card
          LiquidGlassCard(
            gradient: AppColors.purpleFluid,
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
                child: _HabitCard(
                  habit: habit,
                  day: selectedDay,
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

  Future<void> _showCreateHabitDialog(
      BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const CreateHabitDialog(),
    );
  }
}

class _SfCalendarCard extends StatelessWidget {
  const _SfCalendarCard({
    required this.selectedDay,
    required this.appointments,
    required this.onDaySelected,
  });
  final DateTime selectedDay;
  final List<CalendarAppointment> appointments;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(8),
      child: SfCalendar(
        view: CalendarView.month,
        backgroundColor: Colors.transparent,
        selectionDecoration: BoxDecoration(
          color: AppColors.purpleFluidStart.withValues(alpha: 0.25),
          border: Border.all(color: AppColors.purpleFluidStart, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        todayHighlightColor: AppColors.cyanWaterStart,
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
  _HabitDataSource(List<CalendarAppointment> source) {
    appointments = source.cast();
  }

  @override
  DateTime getStartTime(int index) =>
      (appointments as List<CalendarAppointment>)[index].startTime;

  @override
  DateTime getEndTime(int index) =>
      (appointments as List<CalendarAppointment>)[index].endTime;

  @override
  String getSubject(int index) =>
      (appointments as List<CalendarAppointment>)[index].subject;

  @override
  Color getColor(int index) =>
      (appointments as List<CalendarAppointment>)[index].color;
}

/// Espelha `CalendarAppointment` do syncfusion sem importar o tipo
/// (a lib só exporta `Appointment`).
class CalendarAppointment {
  CalendarAppointment({
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.color,
    required this.id,
  });
  final DateTime startTime;
  final DateTime endTime;
  final String subject;
  final Color color;
  final String id;
}

class _HabitCard extends ConsumerWidget {
  const _HabitCard({required this.habit, required this.day});
  final HabitModel habit;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = habit.isCompletedOn(day);
    return LiquidGlassCard(
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
                  'Meta: ${habit.targetValue} ${habit.unit} • ${habit.category}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? AppColors.success : AppColors.textTertiary,
            ),
            onPressed: () {
              ref
                  .read(habitsProvider.notifier)
                  .toggleCompletionForDate(habit, day);
            },
          ),
        ],
      ),
    );
  }
}

/// Diálogo completo de criação de hábito.
///
/// Inclui nome, categoria, grade de ícones, paleta de cores,
/// frequência (dias da semana) e lembrete opcional.
class CreateHabitDialog extends ConsumerStatefulWidget {
  const CreateHabitDialog({super.key});

  @override
  ConsumerState<CreateHabitDialog> createState() => _CreateHabitDialogState();
}

class _CreateHabitDialogState extends ConsumerState<CreateHabitDialog> {
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController(text: 'Geral');
  final _targetCtrl = TextEditingController(text: '1');
  final _unitCtrl = TextEditingController(text: 'vez');

  String _iconKey = 'water';
  String _colorHex = '#06B6D4';
  TimeOfDay? _reminder;
  final Set<int> _frequency = {1, 2, 3, 4, 5, 6, 7};

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

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    await ref.read(habitsProvider.notifier).create(
          title: _titleCtrl.text.trim(),
          category: _categoryCtrl.text.trim(),
          iconKey: _iconKey,
          colorHex: _colorHex,
          frequencyDays: _frequency.toList()..sort(),
          targetValue: int.tryParse(_targetCtrl.text) ?? 1,
          unit: _unitCtrl.text.trim().isEmpty ? 'vez' : _unitCtrl.text.trim(),
          reminderTime: _reminder,
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
                'Novo Hábito',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Nome
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex.: Beber 2L de Água',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                ),
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
                    child: TextField(
                      controller: _targetCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Meta'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _unitCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Unidade (ml, min...)'),
                    ),
                  ),
                ],
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

  String _dayLabel(int weekday) {
    const labels = ['', 'S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return labels[weekday];
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: active ? AppColors.purpleFluid : null,
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
