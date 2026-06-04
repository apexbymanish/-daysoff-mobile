import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_mode_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class DaysoffApp extends ConsumerWidget {
  const DaysoffApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'daysoff',
      debugShowCheckedModeBanner: false,
      theme: DaysoffTheme.light(),
      darkTheme: DaysoffTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
