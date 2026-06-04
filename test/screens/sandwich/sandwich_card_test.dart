import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/sandwich_record.dart';
import 'package:daysoff_mobile/screens/sandwich/widgets/sandwich_card.dart';

SandwichRecord _rec() => SandwichRecord(
      ptoDate: DateTime(2026, 5, 4),
      weekday: 'Monday',
      breakStart: DateTime(2026, 5, 2),
      breakEnd: DateTime(2026, 5, 5),
      breakLength: 4,
      ptoCost: 1,
      context: "Weekend + Children's Day",
    );

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('shows take-off line, break length, context and PTO pill',
      (tester) async {
    await tester.pumpWidget(_host(SandwichCard(record: _rec())));
    expect(find.textContaining('Take Monday'), findsOneWidget);
    expect(find.textContaining('4-day break'), findsOneWidget);
    expect(find.textContaining("Weekend + Children's Day"), findsOneWidget);
    expect(find.text('1 PTO'), findsOneWidget);
  });
}
