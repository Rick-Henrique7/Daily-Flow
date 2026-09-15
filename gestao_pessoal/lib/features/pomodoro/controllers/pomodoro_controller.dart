import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/json_coders.dart';
import '../../habits/data/habits_controller.dart';
import '../data/pomodoro_session_model.dart';

const _uuid = Uuid();

/// Estado interno do timer ativo.
class PomodoroTimerState {
  const PomodoroTimerState({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.type,
    required this.isRunning,
    required this.taskId,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final PomodoroType type;
  final bool isRunning;
  final String? taskId;

  double get progress =>
      totalSeconds == 0 ? 0 : 1 - (remainingSeconds / totalSeconds);

  PomodoroTimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    PomodoroType? type,
    bool? isRunning,
    String? taskId,
    bool clearTaskId = false,
  }) {
    return PomodoroTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      type: type ?? this.type,
      isRunning: isRunning ?? this.isRunning,
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
    );
  }

  static const focus = Duration(minutes: 25);
  static const shortBreak = Duration(minutes: 5);
  static const longBreak = Duration(minutes: 15);
}

/// Notifier principal do timer + histórico de sessões.
class PomodoroTimerNotifier extends Notifier<PomodoroTimerState> {
  Timer? _ticker;
  int _completedFocusCycles = 0;

  @override
  PomodoroTimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const PomodoroTimerState(
      remainingSeconds: 25 * 60,
      totalSeconds: 25 * 60,
      type: PomodoroType.focus,
      isRunning: false,
      taskId: null,
    );
  }

  void selectTask(String? taskId) {
    state = state.copyWith(taskId: taskId, clearTaskId: taskId == null);
  }

  void _setType(PomodoroType type) {
    final seconds = switch (type) {
      PomodoroType.focus => PomodoroTimerState.focus.inSeconds,
      PomodoroType.shortBreak => PomodoroTimerState.shortBreak.inSeconds,
      PomodoroType.longBreak => PomodoroTimerState.longBreak.inSeconds,
    };
    state = state.copyWith(
      type: type,
      totalSeconds: seconds,
      remainingSeconds: seconds,
      isRunning: false,
    );
    _ticker?.cancel();
  }

  void _start() {
    _ticker?.cancel();
    state = state.copyWith(isRunning: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.remainingSeconds <= 1) {
      _ticker?.cancel();
      _completeCycle();
      return;
    }
    state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
  }

  Future<void> _completeCycle() async {
    await _persistSession(isCompleted: true);

    if (state.type == PomodoroType.focus) {
      _completedFocusCycles++;
      if (_completedFocusCycles % 4 == 0) {
        _setType(PomodoroType.longBreak);
      } else {
        _setType(PomodoroType.shortBreak);
      }
    } else {
      _setType(PomodoroType.focus);
    }
  }

  Future<void> _persistSession({required bool isCompleted}) async {
    if (!isCompleted) return;
    final store = ref.read(prefsStoreProvider);
    final history = JsonCoders.decodeList<PomodoroSessionModel>(
      store.pomodoroSessions,
      PomodoroSessionModel.fromJson,
    );
    final session = PomodoroSessionModel(
      id: _uuid.v4(),
      taskId: state.taskId,
      startTime: DateTime.now()
          .subtract(Duration(seconds: state.totalSeconds)),
      durationMinutes: (state.totalSeconds / 60).round(),
      isCompleted: true,
      type: state.type,
    );
    final updated = [...history, session];
    await store.setPomodoroSessions(
      JsonCoders.encodeList<PomodoroSessionModel>(
        updated,
        (s) => s.toJson(),
      ),
    );
  }

  // === API pública ===

  void toggle() {
    if (state.isRunning) {
      _ticker?.cancel();
      state = state.copyWith(isRunning: false);
    } else {
      _start();
    }
  }

  void skip() {
    _ticker?.cancel();
    if (state.type == PomodoroType.focus) {
      _setType(PomodoroType.shortBreak);
    } else {
      _setType(PomodoroType.focus);
    }
  }

  /// Para o timer e reseta o tempo do modo atual para zero (sem mudar modo).
  /// Se quiser voltar ao Foco, basta clicar no chip "Foco".
  void stop() {
    _ticker?.cancel();
    if (state.isRunning) {
      state = state.copyWith(isRunning: false);
    }
  }

  /// Força o tipo de ciclo (Foco / Pausa Curta / Pausa Longa).
  void setType(PomodoroType type) {
    _ticker?.cancel();
    _setType(type);
  }
}

final pomodoroTimerProvider =
    NotifierProvider<PomodoroTimerNotifier, PomodoroTimerState>(
  PomodoroTimerNotifier.new,
);

/// Histórico de sessões concluídas (RF-ST-01).
final pomodoroHistoryProvider = Provider<List<PomodoroSessionModel>>((ref) {
  final store = ref.watch(prefsStoreProvider);
  return JsonCoders.decodeList<PomodoroSessionModel>(
    store.pomodoroSessions,
    PomodoroSessionModel.fromJson,
  );
});
