import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_pessoal/features/tasks/domain/task_schedule.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('TaskSchedule.isScheduledFor', () {
    test('pontual com data de hoje é do dia', () {
      expect(TaskSchedule.isScheduledFor(task(dueDate: thu), thu), isTrue);
    });

    test('pontual com outra data não é do dia', () {
      expect(TaskSchedule.isScheduledFor(task(dueDate: fri), thu), isFalse);
    });

    test('recorrente entra só nos dias da semana configurados', () {
      final t = task(repeatDays: const [2, 4]); // terça e quinta
      expect(TaskSchedule.isScheduledFor(t, thu), isTrue);
      expect(TaskSchedule.isScheduledFor(t, wed), isFalse);
    });

    test('avulsa (sem data e sem recorrência) conta como de hoje', () {
      expect(TaskSchedule.isScheduledFor(task(), thu), isTrue);
    });
  });

  group('TaskSchedule.filter', () {
    final recurring = task(
      id: 'correr',
      repeatDays: const [2, 3, 4, 5],
      completedDates: [tue],
    );
    final doneToday = task(
      id: 'feita',
      dueDate: thu,
      isCompleted: true,
      completedAt: thu,
    );
    final future = task(id: 'futura', dueDate: fri);
    final late = task(id: 'atrasada', dueDate: mon);
    final oldDone = task(
      id: 'antiga',
      dueDate: mon,
      isCompleted: true,
      completedAt: mon,
    );
    final all = [recurring, doneToday, future, late, oldDone];

    List<String> ids(TaskFilter f) =>
        TaskSchedule.filter(all, f, thu).map((t) => t.id).toList();

    test('Hoje: recorrente feita na terça volta a ficar pendente na quinta', () {
      expect(ids(TaskFilter.today), ['correr']);
    });

    test('Próximas: futuras e atrasadas, atrasadas primeiro', () {
      expect(ids(TaskFilter.upcoming), ['atrasada', 'futura']);
    });

    test('Concluídas: pontuais concluídas, mais recentes primeiro', () {
      expect(ids(TaskFilter.completed), ['feita', 'antiga']);
    });

    test('Todas: esconde concluídas de dias passados', () {
      expect(ids(TaskFilter.all), isNot(contains('antiga')));
      expect(ids(TaskFilter.all), containsAll(['correr', 'feita', 'futura']));
    });

    test('Concluídas inclui recorrente feita hoje', () {
      final doneNow = recurring.copyWith(completedDates: [tue, thu]);
      final result = TaskSchedule.filter([doneNow], TaskFilter.completed, thu);
      expect(result, hasLength(1));
    });
  });

  group('TaskSchedule.forDay (painel Hoje)', () {
    test('inclui tarefas feitas hoje para contarem no progresso', () {
      final doneToday = task(id: 'a', isCompleted: true, completedAt: thu);
      final pending = task(id: 'b');
      final result = TaskSchedule.forDay([doneToday, pending], thu);
      expect(result.map((t) => t.id), containsAll(['a', 'b']));
    });

    test('não traz avulsa concluída em outro dia', () {
      final yesterday = task(id: 'a', isCompleted: true, completedAt: wed);
      expect(TaskSchedule.forDay([yesterday], thu), isEmpty);
    });
  });

  test('pendingCount: pontuais abertas + recorrentes de hoje não feitas', () {
    final tasks = [
      task(id: '1'),
      task(id: '2', isCompleted: true, completedAt: thu),
      task(id: '3', repeatDays: const [4]),
      task(id: '4', repeatDays: const [4], completedDates: [thu]),
      task(id: '5', repeatDays: const [1]),
    ];
    expect(TaskSchedule.pendingCount(tasks, thu), 2);
  });
}
