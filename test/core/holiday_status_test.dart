import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/core/holiday_status.dart';

void main() {
  test('absorbed when the holiday lands on a weekend day', () {
    expect(isAbsorbed(DateTime(2026, 1, 3), const ['sat', 'sun']), true);  // Sat
    expect(isAbsorbed(DateTime(2026, 1, 2), const ['sat', 'sun']), false); // Fri
    expect(isAbsorbed(DateTime(2026, 1, 2), const ['fri']), true);
  });
}
