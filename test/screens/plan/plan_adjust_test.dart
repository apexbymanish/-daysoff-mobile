import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/screens/plan/plan_screen.dart';
import 'package:daysoff_mobile/widgets/preferences_editor_sheet.dart';

class _FakeApiClient extends ApiClient {
  @override
  Future<PlanResponse> getPlan({
    required String country,
    required int year,
    int budget = 15,
    int minLength = 3,
    int maxLength = 10,
    List<String>? workweek,
  }) async =>
      PlanResponse(
        country: 'KR',
        year: 2026,
        budget: 15,
        workweek: const ['sat', 'sun'],
        workweekSource: 'user',
        resultsByLength: const <String, List<PlanTrip>>{},
      );
}

void main() {
  testWidgets('Adjust icon button opens the preferences editor', (tester) async {
    // The app bar Adjust text button was replaced with an edit icon button.
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: const MaterialApp(home: PlanScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(PreferencesEditorSheet), findsOneWidget);
  });
}
