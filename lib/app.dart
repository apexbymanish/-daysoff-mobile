import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class DaysoffApp extends StatelessWidget {
  const DaysoffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'daysoff',
      debugShowCheckedModeBanner: false,
      theme: DaysoffTheme.light(),
      darkTheme: DaysoffTheme.dark(),
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
