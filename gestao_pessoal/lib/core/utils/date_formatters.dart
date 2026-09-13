import 'package:intl/intl.dart';

/// Helpers de formatação de data para uso em toda a UI.
class DateFormatters {
  DateFormatters._();

  /// Saudação dinâmica baseada na hora local (RF-DB-04).
  static String greetingForHour(int hour) {
    if (hour >= 5 && hour < 12) return 'Bom dia';
    if (hour >= 12 && hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  /// Data atual por extenso em pt-BR.
  static String fullDate(DateTime date) {
    return DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(date);
  }

  /// Data curta (ex: "12 set").
  static String shortDate(DateTime date) {
    return DateFormat('d MMM', 'pt_BR').format(date);
  }

  /// Dia da semana abreviado (ex: "Seg").
  static String weekdayShort(DateTime date) {
    return DateFormat('E', 'pt_BR').format(date);
  }

  /// Hora HH:mm.
  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Minutos e segundos para o timer Pomodoro (ex: "24:59").
  static String pomodoro(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Verifica se duas datas representam o mesmo dia (ignora hora).
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Número de dias seguidos (streak) entre uma lista de datas e hoje.
  static int currentStreak(List<DateTime> dates, {DateTime? reference}) {
    if (dates.isEmpty) return 0;
    final today = reference ?? DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final sorted = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    var streak = 0;
    var cursor = todayKey;
    while (sorted.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
