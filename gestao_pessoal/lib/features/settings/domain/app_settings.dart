import 'dart:convert';

/// Modo de renderização do fundo da tela.
///
/// - [animated]: gradiente com blobs em loop infinito (default).
/// - [solid]: cor única estática, sem animação (mais leve p/ bateria).
enum WallpaperMode {
  animated,
  solid;

  String get label => switch (this) {
        WallpaperMode.animated => 'Gradiente animado',
        WallpaperMode.solid => 'Cor sólida',
      };

  String get description => switch (this) {
        WallpaperMode.animated =>
          'Blobs de gradiente se movem em loop infinito no fundo.',
        WallpaperMode.solid =>
          'Fundo com uma cor única fixa. Mais leve para a bateria.',
      };
}

/// Modelo imutável de configurações do app.
///
/// Persistido em `SharedPreferences` na chave [PrefsKeys.settings] como JSON.
class AppSettings {
  const AppSettings({
    required this.wallpaperMode,
    required this.wallpaperSeed,
    required this.wallpaperSolidColor,
    required this.wallpaperSaturation,
    required this.blobIntensity,
    required this.hapticsEnabled,
    required this.textColor,
    required this.accentColor,
    required this.soundEnabled,
    required this.pomodoroFocusColor,
    required this.pomodoroShortBreakColor,
    required this.pomodoroLongBreakColor,
  });

  /// Modo de fundo: animado (gradiente) ou sólido.
  final WallpaperMode wallpaperMode;

  /// Cor-base dos blobs do background em HEX (ex: `#8B5CF6`).
  final String wallpaperSeed;

  /// Cor única usada quando [wallpaperMode] é [WallpaperMode.solid].
  final String wallpaperSolidColor;

  /// Saturação dos blobs (0.0 – 1.0).
  final double wallpaperSaturation;

  /// Intensidade/opacidade dos blobs (0.0 – 1.0).
  final double blobIntensity;

  /// Se `true`, vibra a cada interação marcante (concluir tarefa,
  /// hábito, tap em botões). `false` desativa todo feedback tátil.
  final bool hapticsEnabled;

  /// Cor das letras do app em HEX (ex: `#FFFFFF`). Default branco
  /// puro (per design system). Pode ser customizada pelo usuário.
  final String textColor;

  /// Cor de destaque (accent) em HEX (ex: `#00E676` neon green).
  /// Default verde neon. Substitui todas as referências que usariam
  /// `AppColors.primary` — filtro selecionado, FAB, check button,
  /// priority bar, item ativo da nav bar, etc.
  final String accentColor;

  /// Se `true`, toca som de "ding" ao concluir tarefa/hábito.
  final bool soundEnabled;

  /// Cor do anel e label do modo **Foco** no Pomodoro.
  final String pomodoroFocusColor;

  /// Cor do anel e label do modo **Pausa Curta** no Pomodoro.
  final String pomodoroShortBreakColor;

  /// Cor do anel e label do modo **Pausa Longa** no Pomodoro.
  final String pomodoroLongBreakColor;

  static const defaults = AppSettings(
    wallpaperMode: WallpaperMode.solid,
    wallpaperSeed: '#00E676',
    wallpaperSolidColor: '#0D0D0D',
    wallpaperSaturation: 1.0,
    blobIntensity: 0.0,
    hapticsEnabled: true,
    textColor: '#FFFFFF',
    accentColor: '#00E676',
    soundEnabled: true,
    pomodoroFocusColor: '#00E676',
    pomodoroShortBreakColor: '#00B85A',
    pomodoroLongBreakColor: '#1A4D2E',
  );

  AppSettings copyWith({
    WallpaperMode? wallpaperMode,
    String? wallpaperSeed,
    String? wallpaperSolidColor,
    double? wallpaperSaturation,
    double? blobIntensity,
    bool? hapticsEnabled,
    bool? soundEnabled,
    String? textColor,
    String? accentColor,
    String? pomodoroFocusColor,
    String? pomodoroShortBreakColor,
    String? pomodoroLongBreakColor,
  }) {
    return AppSettings(
      wallpaperMode: wallpaperMode ?? this.wallpaperMode,
      wallpaperSeed: wallpaperSeed ?? this.wallpaperSeed,
      wallpaperSolidColor: wallpaperSolidColor ?? this.wallpaperSolidColor,
      wallpaperSaturation: wallpaperSaturation ?? this.wallpaperSaturation,
      blobIntensity: blobIntensity ?? this.blobIntensity,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      textColor: textColor ?? this.textColor,
      accentColor: accentColor ?? this.accentColor,
      pomodoroFocusColor: pomodoroFocusColor ?? this.pomodoroFocusColor,
      pomodoroShortBreakColor:
          pomodoroShortBreakColor ?? this.pomodoroShortBreakColor,
      pomodoroLongBreakColor:
          pomodoroLongBreakColor ?? this.pomodoroLongBreakColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'wallpaperMode': wallpaperMode.name,
        'wallpaperSeed': wallpaperSeed,
        'wallpaperSolidColor': wallpaperSolidColor,
        'wallpaperSaturation': wallpaperSaturation,
        'blobIntensity': blobIntensity,
        'hapticsEnabled': hapticsEnabled,
        'soundEnabled': soundEnabled,
        'textColor': textColor,
        'accentColor': accentColor,
        'pomodoroFocusColor': pomodoroFocusColor,
        'pomodoroShortBreakColor': pomodoroShortBreakColor,
        'pomodoroLongBreakColor': pomodoroLongBreakColor,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final modeName = json['wallpaperMode'] as String?;
    final mode = WallpaperMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => WallpaperMode.animated,
    );
    return AppSettings(
      wallpaperMode: mode,
      wallpaperSeed: json['wallpaperSeed'] as String? ?? '#8B5CF6',
      wallpaperSolidColor:
          json['wallpaperSolidColor'] as String? ?? '#0F172A',
      wallpaperSaturation:
          (json['wallpaperSaturation'] as num?)?.toDouble() ?? 1.0,
      blobIntensity: (json['blobIntensity'] as num?)?.toDouble() ?? 0.35,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      textColor: json['textColor'] as String? ?? '#FFFFFF',
      accentColor: json['accentColor'] as String? ?? '#00E676',
      pomodoroFocusColor:
          json['pomodoroFocusColor'] as String? ?? '#F43F5E',
      pomodoroShortBreakColor:
          json['pomodoroShortBreakColor'] as String? ?? '#06B6D4',
      pomodoroLongBreakColor:
          json['pomodoroLongBreakColor'] as String? ?? '#34D399',
    );
  }

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
