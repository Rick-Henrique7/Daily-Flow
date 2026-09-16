import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_theme.dart';
import 'features/settings/data/settings_controller.dart';
import 'routing/app_router.dart';

class DailyFlowApp extends ConsumerWidget {
  const DailyFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assiste as cores configuradas p/ repassar pro tema — assim
    // todo o app (texto, accent, FAB, nav bar, switches) acompanha.
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'Daily Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkWith(
        textColorHex: settings.textColor,
        accentColorHex: settings.accentColor,
      ),
      darkTheme: AppTheme.darkWith(
        textColorHex: settings.textColor,
        accentColorHex: settings.accentColor,
      ),
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.config,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
