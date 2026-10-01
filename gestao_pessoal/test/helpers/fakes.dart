import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestao_pessoal/core/providers/core_providers.dart';
import 'package:gestao_pessoal/core/services/haptics_service.dart';
import 'package:gestao_pessoal/core/services/sound_service.dart';
import 'package:gestao_pessoal/features/habits/data/prefs_habits_repository.dart';
import 'package:gestao_pessoal/features/habits/domain/habit_model.dart';
import 'package:gestao_pessoal/features/habits/domain/habits_repository.dart';
import 'package:gestao_pessoal/features/pomodoro/data/prefs_pomodoro_sessions_repository.dart';
import 'package:gestao_pessoal/features/pomodoro/domain/pomodoro_session_model.dart';
import 'package:gestao_pessoal/features/pomodoro/domain/pomodoro_sessions_repository.dart';
import 'package:gestao_pessoal/features/settings/data/prefs_settings_repository.dart';
import 'package:gestao_pessoal/features/settings/domain/app_settings.dart';
import 'package:gestao_pessoal/features/settings/domain/settings_repository.dart';
import 'package:gestao_pessoal/features/tasks/data/prefs_tasks_repository.dart';
import 'package:gestao_pessoal/features/tasks/domain/task_model.dart';
import 'package:gestao_pessoal/features/tasks/domain/tasks_repository.dart';

/// Repositórios em memória — possíveis porque os controllers dependem das
/// interfaces do domínio, não do SharedPreferences.
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

class InMemoryHabitsRepository implements HabitsRepository {
  InMemoryHabitsRepository([List<HabitModel>? initial]) : saved = [...?initial];

  List<HabitModel> saved;

  @override
  List<HabitModel> loadAll() => [...saved];

  @override
  Future<void> saveAll(List<HabitModel> habits) async => saved = [...habits];
}

class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this.saved = AppSettings.defaults]);

  AppSettings saved;

  @override
  AppSettings load() => saved;

  @override
  Future<void> save(AppSettings settings) async => saved = settings;
}

class InMemorySessionsRepository implements PomodoroSessionsRepository {
  List<PomodoroSessionModel> saved = [];

  @override
  List<PomodoroSessionModel> loadAll() => [...saved];

  @override
  Future<void> saveAll(List<PomodoroSessionModel> sessions) async =>
      saved = [...sessions];
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

/// Overrides que isolam o app de armazenamento, relógio e plataforma.
List<Override> testOverrides({
  required DateTime today,
  InMemoryTasksRepository? tasks,
  InMemoryHabitsRepository? habits,
  InMemorySettingsRepository? settings,
  InMemorySessionsRepository? sessions,
}) {
  return [
    tasksRepositoryProvider.overrideWithValue(tasks ?? InMemoryTasksRepository()),
    habitsRepositoryProvider
        .overrideWithValue(habits ?? InMemoryHabitsRepository()),
    settingsRepositoryProvider
        .overrideWithValue(settings ?? InMemorySettingsRepository()),
    pomodoroSessionsRepositoryProvider
        .overrideWithValue(sessions ?? InMemorySessionsRepository()),
    todayProvider.overrideWithValue(today),
    hapticsServiceProvider.overrideWithValue(HapticsService(enabled: false)),
    soundServiceProvider.overrideWithValue(SilentSound()),
  ];
}
