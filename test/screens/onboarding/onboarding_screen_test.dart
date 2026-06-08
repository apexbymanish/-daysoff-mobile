import 'package:flutter/material.dart';
import 'package:daysoff_mobile/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:daysoff_mobile/screens/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('renders value prop and Get started enters the app', (tester) async {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
        GoRoute(path: '/', builder: (c, s) => const Scaffold(body: Text('HOME'))),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('daysoff'), findsOneWidget);
    expect(find.textContaining('longest break'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });
}
