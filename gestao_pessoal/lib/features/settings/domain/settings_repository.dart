import 'app_settings.dart';

/// Contrato de persistência das configurações do app.
abstract interface class SettingsRepository {
  AppSettings load();
  Future<void> save(AppSettings settings);
}
