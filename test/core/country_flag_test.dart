import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/core/country_flag.dart';

void main() {
  test('maps ISO-2 codes to regional-indicator flag emoji', () {
    expect(countryFlag('KR'), '🇰🇷');
    expect(countryFlag('np'), '🇳🇵'); // case-insensitive
    expect(countryFlag('US'), '🇺🇸');
  });

  test('non 2-letter codes fall back to globe', () {
    expect(countryFlag('XYZ'), '🌐');
    expect(countryFlag(''), '🌐');
  });
}
