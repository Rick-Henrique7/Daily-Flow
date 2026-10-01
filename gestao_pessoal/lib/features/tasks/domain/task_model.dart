import 'package:flutter/material.dart' show TimeOfDay;

import '../../../core/utils/date_only.dart';
import 'subtask_model.dart';

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.dueDate,
    required this.dueTime,
    required this.repeatDays,
    required this.isCompleted,
    required this.completedAt,
    required this.subtasks,
    required this.orderIndex,
    this.completedDates = const [],
  });

  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final String category;

  /// Data de vencimento (sem hora). `null` = sem data.
  final DateTime? dueDate;

  /// Hora do dia (sem data) em que a tarefa deve ser executada.
  /// Armazenado como `TimeOfDay` mas serializado em JSON como
  /// `{"hour": int, "minute": int}`.
  final TimeOfDay? dueTime;

  /// Dias da semana (1 = Segunda, 7 = Domingo) em que a tarefa se
  /// repete semanalmente. Lista vazia = tarefa pontual.
  final List<int> repeatDays;

  /// Concluída? Vale para tarefas **pontuais**. Tarefas recorrentes
  /// usam [completedDates] (uma conclusão por dia) e mantêm isto `false`.
  final bool isCompleted;

  /// Momento da última conclusão (pontual ou recorrente).
  final DateTime? completedAt;

  /// Dias (sem hora) em que uma tarefa **recorrente** foi feita. Assim
  /// "Correr" feito na terça volta a ficar pendente na quarta.
  final List<DateTime> completedDates;
  final List<SubtaskModel> subtasks;
  final int orderIndex;

  int get completedSubtasksCount =>
      subtasks.where((s) => s.isCompleted).length;

  bool get hasSubtasks => subtasks.isNotEmpty;

  bool get isRepeating => repeatDays.isNotEmpty;

  /// Feita no [day]? Recorrente: olha [completedDates]. Pontual: a
  /// conclusão vale para qualquer dia.
  bool isCompletedOn(DateTime day) => isRepeating
      ? completedDates.any((d) => isSameDay(d, day))
      : isCompleted;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    TaskPriority? priority,
    String? category,
    DateTime? dueDate,
    bool clearDueDate = false,
    TimeOfDay? dueTime,
    bool clearDueTime = false,
    List<int>? repeatDays,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    List<SubtaskModel>? subtasks,
    int? orderIndex,
    List<DateTime>? completedDates,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      dueTime: clearDueTime ? null : (dueTime ?? this.dueTime),
      repeatDays: repeatDays ?? this.repeatDays,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      subtasks: subtasks ?? this.subtasks,
      orderIndex: orderIndex ?? this.orderIndex,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority.code,
        'category': category,
        'dueDate': dueDate?.toIso8601String(),
        'dueTime': dueTime == null
            ? null
            : {'hour': dueTime!.hour, 'minute': dueTime!.minute},
        'repeatDays': repeatDays,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'orderIndex': orderIndex,
        'completedDates':
            completedDates.map((d) => dateOnly(d).toIso8601String()).toList(),
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final dueTimeJson = json['dueTime'];
    TimeOfDay? parsedTime;
    if (dueTimeJson is Map<String, dynamic>) {
      parsedTime = TimeOfDay(
        hour: dueTimeJson['hour'] as int? ?? 0,
        minute: dueTimeJson['minute'] as int? ?? 0,
      );
    }
    final repeatDays =
        ((json['repeatDays'] as List<dynamic>?) ?? const <int>[]).cast<int>();
    var isCompleted = json['isCompleted'] as bool;
    final completedAt = json['completedAt'] == null
        ? null
        : DateTime.parse(json['completedAt'] as String);
    var completedDates = ((json['completedDates'] as List<dynamic>?) ?? const [])
        .map((e) => DateTime.parse(e as String))
        .toList();

    // Migração (v0.1 → v0.2): recorrentes guardavam um único
    // `isCompleted`. Converte para uma conclusão no dia em que foi feita.
    if (repeatDays.isNotEmpty && isCompleted) {
      if (completedAt != null && completedDates.isEmpty) {
        completedDates = [dateOnly(completedAt)];
      }
      isCompleted = false;
    }

    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: TaskPriority.values.firstWhere(
        (p) => p.code == json['priority'] as String,
        orElse: () => TaskPriority.medium,
      ),
      category: json['category'] as String,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      dueTime: parsedTime,
      repeatDays: repeatDays,
      isCompleted: isCompleted,
      completedAt: completedAt,
      completedDates: completedDates,
      subtasks: (json['subtasks'] as List<dynamic>)
          .map((e) => SubtaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      orderIndex: json['orderIndex'] as int,
    );
  }
}
