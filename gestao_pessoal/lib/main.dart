import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'app.dart';
import 'core/database/prefs_store.dart';
import 'features/habits/data/habits_controller.dart';

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
      ],
      child: LiquidGlassWidgets.wrap(child: const DailyFlowApp()),
    ),
  );
}
