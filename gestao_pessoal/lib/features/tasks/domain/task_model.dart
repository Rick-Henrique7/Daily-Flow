import 'package:flutter/material.dart' show TimeOfDay;

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

  final bool isCompleted;
  final DateTime? completedAt;
  final List<SubtaskModel> subtasks;
  final int orderIndex;

  int get completedSubtasksCount =>
      subtasks.where((s) => s.isCompleted).length;

  bool get hasSubtasks => subtasks.isNotEmpty;

  bool get isRepeating => repeatDays.isNotEmpty;

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
      repeatDays:
          ((json['repeatDays'] as List<dynamic>?) ?? const <int>[]).cast<int>(),
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      subtasks: (json['subtasks'] as List<dynamic>)
          .map((e) => SubtaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      orderIndex: json['orderIndex'] as int,
    );
  }
}
