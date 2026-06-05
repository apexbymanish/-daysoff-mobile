import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/core/plan_value.dart';

PlanTrip _t(int len, int pto) => PlanTrip(
      breakStart: DateTime(2026, 1, 1),
      breakEnd: DateTime(2026, 1, len),
      breakLength: len,
      ptoDates: const [],
      ptoCost: pto,
      anchors: const ['X'],
    );

void main() {
  test('null for empty', () => expect(bestValueTrip(const []), isNull));

  test('a 0-PTO 3-day beats a 2-PTO 5-day', () {
    final best = bestValueTrip([_t(5, 2), _t(3, 0)]);
    expect(best!.breakLength, 3);
    expect(best.ptoCost, 0);
  });

  test('tie on ratio → fewer PTO wins', () {
    final best = bestValueTrip([_t(4, 2), _t(2, 1)]);
    expect(best!.ptoCost, 1);
  });
}
