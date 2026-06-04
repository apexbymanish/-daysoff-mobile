import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/country.dart';
import 'package:daysoff_mobile/providers/countries_provider.dart';
import 'package:daysoff_mobile/providers/selection_provider.dart';
import 'package:daysoff_mobile/screens/country_picker/country_picker_screen.dart';

void main() {
  testWidgets('tapping a country sets selectedCountryProvider', (tester) async {
    final container = ProviderContainer(overrides: [
      countriesProvider.overrideWith((ref) async => const [
            Country(code: 'KR', name: 'South Korea', newsEnriched: true),
            Country(code: 'NP', name: 'Nepal', newsEnriched: false),
          ]),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: CountryPickerScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nepal'));
    await tester.pumpAndSettle();

    expect(container.read(selectedCountryProvider), 'NP');
  });

  testWidgets('search filters the list', (tester) async {
    final container = ProviderContainer(overrides: [
      countriesProvider.overrideWith((ref) async => const [
            Country(code: 'KR', name: 'South Korea', newsEnriched: true),
            Country(code: 'JP', name: 'Japan', newsEnriched: false),
          ]),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: CountryPickerScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'jap');
    await tester.pumpAndSettle();
    expect(find.text('Japan'), findsOneWidget);
    expect(find.text('South Korea'), findsNothing);
  });
}
