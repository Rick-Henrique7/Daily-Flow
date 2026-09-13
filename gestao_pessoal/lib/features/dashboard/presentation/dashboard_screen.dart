import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../../habits/data/habits_controller.dart';
import '../../tasks/data/tasks_controller.dart';
import '../../tasks/domain/subtask_model.dart';
import 'daily_progress_ring.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final habitsToday = ref.watch(habitsForDayProvider(now));
    final tasks = ref.watch(tasksProvider);
    final todayTasks = tasks.where((t) {
      if (t.isCompleted) return false;
      if (t.dueDate == null) return false;
      final d = t.dueDate!;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    final habitsDone = habitsToday.where((h) => h.isCompletedOn(now)).length;
    final totalItems = habitsToday.length + todayTasks.length;
    final doneItems = habitsDone + todayTasks.where((t) => t.isCompleted).length;
    final progress = totalItems == 0 ? 0.0 : doneItems / totalItems;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormatters.greetingForHour(now.hour),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Daily Flow',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormatters.fullDate(now),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Configurações',
                      icon: const Icon(Icons.tune,
                          color: AppColors.textPrimary),
                      onPressed: () => context.go('/settings'),
                    ),
                  ],
                ),
              ),
            ),
            // Espaçamento para centralizar verticalmente o anel no espaço
            // disponível entre o header e a próxima seção.
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
            SliverToBoxAdapter(
              child: Center(
                child: DailyProgressRing(
                  progress: progress,
                  label: '$doneItems/$totalItems concluídos',
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(.9, .9)),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Hoje no Radar',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            if (habitsToday.isEmpty && todayTasks.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: LiquidGlassCard(
                    child: Row(
                      children: [
                        Icon(Icons.celebration_outlined,
                            color: AppColors.success),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tudo vazio por hoje. Crie um hábito ou tarefa pelo botão +.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: habitsToday.length + todayTasks.length,
                itemBuilder: (context, index) {
                  if (index < habitsToday.length) {
                    final habit = habitsToday[index];
                    final done = habit.isCompletedOn(now);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: LiquidGlassCard(
                        child: ListTile(
                          leading: Icon(habit.icon, color: habit.color),
                          title: Text(habit.title),
                          trailing: Checkbox(
                            value: done,
                            onChanged: (_) {
                              ref
                                  .read(habitsProvider.notifier)
                                  .toggleCompletionForDate(habit, now);
                            },
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: .1);
                  }
                  final task = todayTasks[index - habitsToday.length];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: LiquidGlassCard(
                      child: ListTile(
                        leading: Icon(task.priority.icon, color: task.priority.color),
                        title: Text(task.title),
                        subtitle: Text(
                          task.category,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          onPressed: () {
                            ref.read(tasksProvider.notifier).toggleCompleted(task);
                          },
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: .1);
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.water_drop_outlined,
                  color: AppColors.cyanWaterStart),
              title: const Text('Novo Hábito'),
              onTap: () {
                Navigator.pop(context);
                context.go('/habits');
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt, color: AppColors.purpleFluidStart),
              title: const Text('Nova Tarefa'),
              onTap: () {
                Navigator.pop(context);
                context.go('/tasks');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Stub legado removido — navegação agora é responsabilidade do AppShell.
