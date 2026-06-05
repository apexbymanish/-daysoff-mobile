import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/providers/preferences_provider.dart';

void main() {
  test('providers expose coded defaults (15 / 3-10 / sat,sun)', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(ptoBudgetProvider), 15);
    expect(c.read(breakLengthProvider), const BreakLengthRange(min: 3, max: 10));
    expect(c.read(weekendProvider), const ['sat', 'sun']);
  });

  test('BreakLengthRange equality + copyWith', () {
    const r = BreakLengthRange(min: 3, max: 10);
    expect(r.copyWith(max: 7), const BreakLengthRange(min: 3, max: 7));
    expect(r, const BreakLengthRange(min: 3, max: 10));
    expect(r == const BreakLengthRange(min: 4, max: 10), false);
  });

  test('formatWeekend orders by week and labels', () {
    expect(formatWeekend(const ['sun', 'sat']), 'Sat, Sun');
    expect(formatWeekend(const ['fri']), 'Fri');
  });
}
