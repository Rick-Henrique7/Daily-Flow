enum PomodoroType { focus, shortBreak, longBreak }

extension PomodoroTypeX on PomodoroType {
  String get label {
    switch (this) {
      case PomodoroType.focus:
        return 'Foco';
      case PomodoroType.shortBreak:
        return 'Pausa Curta';
      case PomodoroType.longBreak:
        return 'Pausa Longa';
    }
  }

  String get code => name;
}

class PomodoroSessionModel {
  const PomodoroSessionModel({
    required this.id,
    required this.taskId,
    required this.startTime,
    required this.durationMinutes,
    required this.isCompleted,
    required this.type,
  });

  final String id;
  final String? taskId;
  final DateTime startTime;
  final int durationMinutes;
  final bool isCompleted;
  final PomodoroType type;

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'startTime': startTime.toIso8601String(),
        'durationMinutes': durationMinutes,
        'isCompleted': isCompleted,
        'type': type.code,
      };

  factory PomodoroSessionModel.fromJson(Map<String, dynamic> json) =>
      PomodoroSessionModel(
        id: json['id'] as String,
        taskId: json['taskId'] as String?,
        startTime: DateTime.parse(json['startTime'] as String),
        durationMinutes: json['durationMinutes'] as int,
        isCompleted: json['isCompleted'] as bool,
        type: PomodoroType.values.firstWhere(
          (t) => t.code == json['type'] as String,
          orElse: () => PomodoroType.focus,
        ),
      );
}
