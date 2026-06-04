import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/country.dart';
import 'package:daysoff_mobile/api/models/countries_response.dart';

void main() {
  test('Country.fromJson maps news_enriched', () {
    final c = Country.fromJson(const {'code': 'KR', 'name': 'South Korea', 'news_enriched': true});
    expect(c.code, 'KR');
    expect(c.name, 'South Korea');
    expect(c.newsEnriched, true);
  });

  test('CountriesResponse.fromJson parses list', () {
    final r = CountriesResponse.fromJson(const {
      'count': 1,
      'countries': [{'code': 'KR', 'name': 'South Korea', 'news_enriched': true}],
    });
    expect(r.count, 1);
    expect(r.countries.single.code, 'KR');
  });
}
