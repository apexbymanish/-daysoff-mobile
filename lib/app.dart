import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_mode_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class DaysoffApp extends ConsumerWidget {
  const DaysoffApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'daysoff',
      debugShowCheckedModeBanner: false,
      theme: DaysoffTheme.light(),
      darkTheme: DaysoffTheme.dark(),
      themeMode: themeMode,
      locale: locale, // null → follow the system locale
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
