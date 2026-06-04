import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/core/break_days.dart';

void main() {
  final pto = [DateTime(2026, 9, 23)];

  test('classifies pto / weekend / holiday', () {
    expect(classifyBreakDay(DateTime(2026, 9, 23), pto), BreakDayKind.pto);
    expect(classifyBreakDay(DateTime(2026, 9, 26), pto), BreakDayKind.weekend); // Saturday
    expect(classifyBreakDay(DateTime(2026, 9, 25), pto), BreakDayKind.holiday); // Friday, not PTO
  });
}
