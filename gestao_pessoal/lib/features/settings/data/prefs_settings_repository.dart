import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/prefs_store.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// [SettingsRepository] sobre `SharedPreferences`.
class PrefsSettingsRepository implements SettingsRepository {
  PrefsSettingsRepository(this._store);

  final PrefsStore _store;

  @override
  AppSettings load() => AppSettings.fromJsonString(_store.settings);

  @override
  Future<void> save(AppSettings settings) =>
      _store.setSettings(settings.toJsonString());
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => PrefsSettingsRepository(ref.watch(prefsStoreProvider)),
);
