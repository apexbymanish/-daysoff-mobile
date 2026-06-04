import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/providers/holidays_provider.dart';
import 'package:daysoff_mobile/providers/selection_provider.dart';
import 'package:daysoff_mobile/screens/home/home_screen.dart';

void main() {
  testWidgets('Home queries holidays for the SELECTED country/year', (tester) async {
    var askedCountry = '';
    var askedYear = 0;
    final container = ProviderContainer(overrides: [
      // selected = NP / 2027
      selectedCountryProvider.overrideWith((ref) => 'NP'),
      selectedYearProvider.overrideWith((ref) => 2027),
      holidaysProvider(const HolidaysQuery(country: 'NP', year: 2027)).overrideWith((ref) async {
        askedCountry = 'NP';
        askedYear = 2027;
        return const HolidaysResponse(country: 'NP', year: 2027, count: 0, holidays: []);
      }),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: GoRouter(routes: [
          GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        ]),
      ),
    ));
    await tester.pumpAndSettle();

    expect(askedCountry, 'NP');
    expect(askedYear, 2027);
  });
}
