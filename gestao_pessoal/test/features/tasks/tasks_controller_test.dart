import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_pessoal/core/providers/core_providers.dart';
import 'package:gestao_pessoal/core/services/haptics_service.dart';
import 'package:gestao_pessoal/core/services/sound_service.dart';
import 'package:gestao_pessoal/features/tasks/data/prefs_tasks_repository.dart';
import 'package:gestao_pessoal/features/tasks/data/tasks_controller.dart';
import 'package:gestao_pessoal/features/tasks/domain/task_model.dart';
import 'package:gestao_pessoal/features/tasks/domain/tasks_repository.dart';

import '../../helpers/fixtures.dart';

/// Repositório em memória — possível porque o controller depende da
/// interface [TasksRepository], não do SharedPreferences.
class InMemoryTasksRepository implements TasksRepository {
  InMemoryTasksRepository([List<TaskModel>? initial]) : saved = [...?initial];

  List<TaskModel> saved;
  int saveCalls = 0;

  @override
  List<TaskModel> loadAll() => [...saved];

  @override
  Future<void> saveAll(List<TaskModel> tasks) async {
    saved = [...tasks];
    saveCalls++;
  }
}

/// Som silencioso: não cria AudioPlayer (sem plugin nativo no teste).
class SilentSound implements SoundService {
  @override
  bool get enabled => false;
  @override
  Future<void> playSuccess() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  late InMemoryTasksRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = InMemoryTasksRepository([
      task(id: 'correr', repeatDays: const [2, 3, 4, 5]),
    ]);
    container = ProviderContainer(overrides: [
      tasksRepositoryProvider.overrideWithValue(repo),
      todayProvider.overrideWithValue(thu),
      hapticsServiceProvider.overrideWithValue(HapticsService(enabled: false)),
      soundServiceProvider.overrideWithValue(SilentSound()),
    ]);
  });

  tearDown(() => container.dispose());

  test('concluir recorrente grava o dia e persiste no repositório', () async {
    final notifier = container.read(tasksProvider.notifier);
    await notifier.toggleCompleted(container.read(tasksProvider).single);

    final t = container.read(tasksProvider).single;
    expect(t.isCompletedOn(thu), isTrue);
    expect(t.isCompleted, isFalse);
    expect(repo.saveCalls, 1);
    expect(repo.saved.single.completedDates, [thu]);
  });

  test('recorrente feita hoje sai de "Hoje" e reaparece no dia seguinte',
      () async {
    final notifier = container.read(tasksProvider.notifier);
    await notifier.toggleCompleted(container.read(tasksProvider).single);
    container.read(taskFilterProvider.notifier).state = TaskFilter.today;
    expect(container.read(filteredTasksProvider), isEmpty);

    final t = container.read(tasksProvider).single;
    expect(TaskSchedule.isDoneOn(t, fri), isFalse);
  });

  test('desmarcar remove só a conclusão daquele dia', () async {
    final notifier = container.read(tasksProvider.notifier);
    var t = container.read(tasksProvider).single;
    await notifier.toggleCompleted(t, on: wed);
    t = container.read(tasksProvider).single;
    await notifier.toggleCompleted(t); // hoje
    t = container.read(tasksProvider).single;
    await notifier.toggleCompleted(t); // desfaz hoje

    expect(container.read(tasksProvider).single.completedDates, [wed]);
  });

  test('tela Hoje recebe a recorrente do dia mesmo depois de feita', () async {
    final notifier = container.read(tasksProvider.notifier);
    await notifier.toggleCompleted(container.read(tasksProvider).single);
    expect(container.read(todayTasksProvider), hasLength(1));
    expect(container.read(pendingTasksCountProvider), 0);
  });
}
