import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/screens/home/widgets/next_break_hero.dart';

void main() {
  testWidgets('renders the label + holiday name and fires See details',
      (tester) async {
    var tapped = false;
    final next = Holiday(
      date: DateTime.now().add(const Duration(days: 12)),
      name: 'Children\'s Day',
      source: 'library',
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NextBreakHero(next: next, onSeeDetails: () => tapped = true),
      ),
    ));
    await tester.pump();

    expect(find.text('NEXT BREAK IN'), findsOneWidget);
    expect(find.text("Children's Day"), findsOneWidget);

    await tester.tap(find.text('See details'));
    await tester.pump();
    expect(tapped, true);
  });
}
