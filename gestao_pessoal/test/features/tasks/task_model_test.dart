import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_pessoal/features/tasks/domain/task_model.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('toJson -> fromJson preserva completedDates', () {
    final original = task(repeatDays: const [2, 4], completedDates: [tue, thu]);
    final copy = TaskModel.fromJson(original.toJson());
    expect(copy.completedDates, [tue, thu]);
    expect(copy.isCompletedOn(thu), isTrue);
    expect(copy.isCompletedOn(wed), isFalse);
  });

  test('migração: recorrente antiga marcada como concluída vira conclusão do dia',
      () {
    final legacy = task(repeatDays: const [2, 4]).toJson()
      ..['isCompleted'] = true
      ..['completedAt'] = DateTime(2026, 9, 29, 7, 30).toIso8601String()
      ..remove('completedDates');

    final migrated = TaskModel.fromJson(legacy);

    expect(migrated.isCompleted, isFalse);
    expect(migrated.completedDates, [tue]);
    expect(migrated.isCompletedOn(thu), isFalse); // volta a ficar pendente
  });

  test('pontual: isCompletedOn ignora o dia', () {
    final t = task(isCompleted: true, completedAt: mon);
    expect(t.isCompletedOn(thu), isTrue);
  });
}
