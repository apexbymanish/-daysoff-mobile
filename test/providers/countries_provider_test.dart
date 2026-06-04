import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/countries_response.dart';
import 'package:daysoff_mobile/api/models/country.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/providers/countries_provider.dart';

class _FakeApi extends ApiClient {
  @override
  Future<CountriesResponse> getCountries() async => const CountriesResponse(
        count: 1,
        countries: [Country(code: 'KR', name: 'South Korea', newsEnriched: true)],
      );
}

void main() {
  test('countriesProvider returns the ApiClient list', () async {
    final c = ProviderContainer(overrides: [apiClientProvider.overrideWithValue(_FakeApi())]);
    addTearDown(c.dispose);
    final list = await c.read(countriesProvider.future);
    expect(list.single.code, 'KR');
  });
}
