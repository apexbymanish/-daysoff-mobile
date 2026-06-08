import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/app.dart';
import 'package:daysoff_mobile/providers/holidays_provider.dart';

void main() {
  testWidgets('App boots to Home (empty) inside the nav shell, no network',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          holidaysProvider(const HolidaysQuery(country: 'KR', year: 2026))
              .overrideWith(
            (ref) async => const HolidaysResponse(
              country: 'KR', year: 2026, count: 0, holidays: [],
            ),
          ),
        ],
        child: const DaysoffApp(),
      ),
    );
    await tester.pumpAndSettle();
    // App opens on the Welcome screen; enter the app.
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    // Custom 3-tab bar renders the localized labels.
    expect(find.text('Holidays'), findsWidgets);
    expect(find.text('No holidays for this year.'), findsOneWidget);
  });
}
