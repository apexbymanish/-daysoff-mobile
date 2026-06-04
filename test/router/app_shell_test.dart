import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/app.dart';
import 'package:daysoff_mobile/providers/holidays_provider.dart';
import 'package:daysoff_mobile/screens/settings/settings_screen.dart';

void main() {
  testWidgets('shell shows 4 nav destinations and can switch to Settings',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        holidaysProvider(const HolidaysQuery(country: 'KR', year: 2026))
            .overrideWith((ref) async => const HolidaysResponse(
                  country: 'KR', year: 2026, count: 0, holidays: [],
                )),
      ],
      child: const DaysoffApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Holidays'), findsWidgets);
    expect(find.text('Plan'), findsWidgets);
    expect(find.text('Sandwich'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
