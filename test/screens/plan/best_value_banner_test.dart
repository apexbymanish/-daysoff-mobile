import 'package:flutter/material.dart';
import 'package:daysoff_mobile/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/screens/plan/widgets/best_value_banner.dart';

void main() {
  testWidgets('shows the length + PTO text', (tester) async {
    final t = PlanTrip(
      breakStart: DateTime(2026, 9, 23),
      breakEnd: DateTime(2026, 9, 27),
      breakLength: 5,
      ptoDates: const [],
      ptoCost: 1,
      anchors: const ['Chuseok'],
    );
    await tester.pumpWidget(
        MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, home: Scaffold(body: BestValueBanner(trip: t))));
    expect(find.textContaining('Best value'), findsOneWidget);
    expect(find.textContaining('5-day'), findsOneWidget);
  });
}
