import 'dart:convert';

/// Modelo imutável de configurações do app.
///
/// Persistido em `SharedPreferences` na chave [PrefsKeys.settings] como JSON.
class AppSettings {
  const AppSettings({
    required this.wallpaperSeed,
    required this.wallpaperSaturation,
    required this.blobIntensity,
    required this.darkMode,
    required this.pomodoroFocusColor,
    required this.pomodoroShortBreakColor,
    required this.pomodoroLongBreakColor,
  });

  /// Cor-base dos blobs do background em HEX (ex: `#8B5CF6`).
  final String wallpaperSeed;

  /// Saturação dos blobs (0.0 – 1.0).
  final double wallpaperSaturation;

  /// Intensidade/opacidade dos blobs (0.0 – 1.0).
  final double blobIntensity;

  /// Se `true`, mantém o Dark Mode; `false` (futuro) usaria Light.
  final bool darkMode;

  /// Cor do anel e label do modo **Foco** no Pomodoro.
  final String pomodoroFocusColor;

  /// Cor do anel e label do modo **Pausa Curta** no Pomodoro.
  final String pomodoroShortBreakColor;

  /// Cor do anel e label do modo **Pausa Longa** no Pomodoro.
  final String pomodoroLongBreakColor;

  static const defaults = AppSettings(
    wallpaperSeed: '#8B5CF6',
    wallpaperSaturation: 1.0,
    blobIntensity: 0.35,
    darkMode: true,
    pomodoroFocusColor: '#F43F5E',
    pomodoroShortBreakColor: '#06B6D4',
    pomodoroLongBreakColor: '#34D399',
  );

  AppSettings copyWith({
    String? wallpaperSeed,
    double? wallpaperSaturation,
    double? blobIntensity,
    bool? darkMode,
    String? pomodoroFocusColor,
    String? pomodoroShortBreakColor,
    String? pomodoroLongBreakColor,
  }) {
    return AppSettings(
      wallpaperSeed: wallpaperSeed ?? this.wallpaperSeed,
      wallpaperSaturation: wallpaperSaturation ?? this.wallpaperSaturation,
      blobIntensity: blobIntensity ?? this.blobIntensity,
      darkMode: darkMode ?? this.darkMode,
      pomodoroFocusColor: pomodoroFocusColor ?? this.pomodoroFocusColor,
      pomodoroShortBreakColor:
          pomodoroShortBreakColor ?? this.pomodoroShortBreakColor,
      pomodoroLongBreakColor:
          pomodoroLongBreakColor ?? this.pomodoroLongBreakColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'wallpaperSeed': wallpaperSeed,
        'wallpaperSaturation': wallpaperSaturation,
        'blobIntensity': blobIntensity,
        'darkMode': darkMode,
        'pomodoroFocusColor': pomodoroFocusColor,
        'pomodoroShortBreakColor': pomodoroShortBreakColor,
        'pomodoroLongBreakColor': pomodoroLongBreakColor,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        wallpaperSeed: json['wallpaperSeed'] as String? ?? '#8B5CF6',
        wallpaperSaturation:
            (json['wallpaperSaturation'] as num?)?.toDouble() ?? 1.0,
        blobIntensity: (json['blobIntensity'] as num?)?.toDouble() ?? 0.35,
        darkMode: json['darkMode'] as bool? ?? true,
        pomodoroFocusColor:
            json['pomodoroFocusColor'] as String? ?? '#F43F5E',
        pomodoroShortBreakColor:
            json['pomodoroShortBreakColor'] as String? ?? '#06B6D4',
        pomodoroLongBreakColor:
            json['pomodoroLongBreakColor'] as String? ?? '#34D399',
      );

  String toJsonString() => jsonEncode(toJson());

  static AppSettings fromJsonString(String? source) {
    if (source == null || source.isEmpty) return defaults;
    try {
      final raw = jsonDecode(source);
      if (raw is Map<String, dynamic>) return AppSettings.fromJson(raw);
    } catch (_) {}
    return defaults;
  }
}
