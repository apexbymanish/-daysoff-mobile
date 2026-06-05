import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';

void main() {
  test('parses name_local into nameLocal; absent → null', () {
    final h = Holiday.fromJson({
      'date': '2026-02-17', 'name': 'Korean New Year',
      'name_local': '설날', 'source': 'library',
    });
    expect(h.nameLocal, '설날');

    final h2 = Holiday.fromJson({
      'date': '2026-01-01', 'name': 'New Year', 'source': 'library',
    });
    expect(h2.nameLocal, isNull);
  });
}
