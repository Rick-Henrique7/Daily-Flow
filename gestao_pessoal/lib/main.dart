import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'app.dart';
import 'core/database/prefs_store.dart';
import 'core/providers/core_providers.dart';
import 'features/settings/data/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pré-aquece shaders do Liquid Glass (iOS 26 design language).
  await LiquidGlassWidgets.initialize();

  // Locale pt-BR para `DateFormat('pt_BR')`.
  await initializeDateFormatting('pt_BR');

  final store = await PrefsStore.open();

  runApp(
    ProviderScope(
      overrides: [
        prefsStoreProvider.overrideWithValue(store),
        // Liga a "porta" de feedback do core às configurações do usuário.
        feedbackPreferencesProvider.overrideWith((ref) {
          final s = ref.watch(settingsProvider);
          return FeedbackPreferences(
            haptics: s.hapticsEnabled,
            sound: s.soundEnabled,
          );
        }),
      ],
      child: LiquidGlassWidgets.wrap(child: const DailyFlowApp()),
    ),
  );
}
