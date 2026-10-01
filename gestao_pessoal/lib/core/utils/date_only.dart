/// Remove hora/minuto/segundo de uma data — usada como "dia" nas regras.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// `true` se [a] e [b] caem no mesmo dia do calendário.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
