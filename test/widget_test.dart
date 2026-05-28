import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/app.dart';
import 'package:daysoff_mobile/providers/holidays_provider.dart';

void main() {
  testWidgets('App builds and shows empty Home without hitting the network',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          holidaysProvider(const HolidaysQuery(country: 'KR', year: 2026))
              .overrideWith(
            (ref) async => const HolidaysResponse(
              country: 'KR',
              year: 2026,
              count: 0,
              holidays: [],
            ),
          ),
        ],
        child: const DaysoffApp(),
      ),
    );

    // Let the future resolve.
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('No holidays for this year.'), findsOneWidget);
  });
}
