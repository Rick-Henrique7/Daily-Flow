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
  });

  /// Cor-base dos blobs do background em HEX (ex: `#8B5CF6`).
  final String wallpaperSeed;

  /// Saturação dos blobs (0.0 – 1.0).
  final double wallpaperSaturation;

  /// Intensidade/opacidade dos blobs (0.0 – 1.0).
  final double blobIntensity;

  /// Se `true`, mantém o Dark Mode; `false` (futuro) usaria Light.
  final bool darkMode;

  static const defaults = AppSettings(
    wallpaperSeed: '#8B5CF6',
    wallpaperSaturation: 1.0,
    blobIntensity: 0.35,
    darkMode: true,
  );

  AppSettings copyWith({
    String? wallpaperSeed,
    double? wallpaperSaturation,
    double? blobIntensity,
    bool? darkMode,
  }) {
    return AppSettings(
      wallpaperSeed: wallpaperSeed ?? this.wallpaperSeed,
      wallpaperSaturation: wallpaperSaturation ?? this.wallpaperSaturation,
      blobIntensity: blobIntensity ?? this.blobIntensity,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'wallpaperSeed': wallpaperSeed,
        'wallpaperSaturation': wallpaperSaturation,
        'blobIntensity': blobIntensity,
        'darkMode': darkMode,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        wallpaperSeed: json['wallpaperSeed'] as String? ?? '#8B5CF6',
        wallpaperSaturation:
            (json['wallpaperSaturation'] as num?)?.toDouble() ?? 1.0,
        blobIntensity: (json['blobIntensity'] as num?)?.toDouble() ?? 0.35,
        darkMode: json['darkMode'] as bool? ?? true,
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
