import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/providers/selection_provider.dart';

void main() {
  test('defaults to KR / 2026 and updates', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(selectedCountryProvider), 'KR');
    expect(c.read(selectedYearProvider), 2026);
    c.read(selectedCountryProvider.notifier).state = 'NP';
    c.read(selectedYearProvider.notifier).state = 2027;
    expect(c.read(selectedCountryProvider), 'NP');
    expect(c.read(selectedYearProvider), 2027);
  });
}
