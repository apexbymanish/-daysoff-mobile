import 'package:flutter/material.dart';
import 'package:daysoff_mobile/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/sandwich_record.dart';
import 'package:daysoff_mobile/screens/sandwich/widgets/efficiency_insight.dart';

List<SandwichRecord> _records() => [
      SandwichRecord(
        ptoDate: DateTime(2026, 5, 4),
        weekday: 'Monday',
        breakStart: DateTime(2026, 5, 2),
        breakEnd: DateTime(2026, 5, 5),
        breakLength: 4,
        ptoCost: 1,
        context: "Weekend + Children's Day",
      ),
      SandwichRecord(
        ptoDate: DateTime(2026, 10, 9),
        weekday: 'Friday',
        breakStart: DateTime(2026, 10, 8),
        breakEnd: DateTime(2026, 10, 11),
        breakLength: 4,
        ptoCost: 1,
        context: 'Hangul Day bridge',
      ),
    ];

Widget _host(Widget child) => MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, home: Scaffold(body: child));

void main() {
  testWidgets('shows ratio for known records', (tester) async {
    // totalBreakDays = 4+4 = 8, totalPto = 1+1 = 2, ratio = 8/2 = 4
    await tester.pumpWidget(_host(EfficiencyInsight(records: _records())));
    expect(find.textContaining('4:1'), findsOneWidget);
    expect(find.textContaining('EFFICIENCY INSIGHT'), findsOneWidget);
  });

  testWidgets('returns SizedBox.shrink for empty records', (tester) async {
    await tester.pumpWidget(_host(const EfficiencyInsight(records: [])));
    // No EFFICIENCY INSIGHT text rendered
    expect(find.textContaining('EFFICIENCY INSIGHT'), findsNothing);
  });
}
