import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/app.dart';
import 'package:daysoff_mobile/providers/holidays_provider.dart';
import 'package:daysoff_mobile/screens/settings/settings_screen.dart';

void main() {
  testWidgets('shell shows 3 custom nav tabs and can switch to Settings',
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

    // Custom 3-tab bar — labels are uppercase.
    expect(find.text('HOLIDAYS'), findsWidgets);
    expect(find.text('PLAN'), findsWidgets);
    expect(find.text('SETTINGS'), findsWidgets);

    // No Sandwich tab.
    expect(find.text('Sandwich'), findsNothing);
    expect(find.text('SANDWICH'), findsNothing);

    await tester.tap(find.text('SETTINGS'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
