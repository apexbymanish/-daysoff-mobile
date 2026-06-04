import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';

void main() {
  const tripJson = {
    'break_start': '2026-09-23',
    'break_end': '2026-09-27',
    'break_length': 5,
    'pto_dates': ['2026-09-23'],
    'pto_cost': 1,
    'anchors': ['Chuseok'],
  };

  test('PlanTrip.fromJson maps snake_case + dates', () {
    final t = PlanTrip.fromJson(tripJson);
    expect(t.breakStart, DateTime(2026, 9, 23));
    expect(t.breakEnd, DateTime(2026, 9, 27));
    expect(t.breakLength, 5);
    expect(t.ptoDates, [DateTime(2026, 9, 23)]);
    expect(t.ptoCost, 1);
    expect(t.anchors, ['Chuseok']);
  });

  test('PlanResponse.fromJson parses results_by_length map', () {
    final r = PlanResponse.fromJson({
      'country': 'KR',
      'year': 2026,
      'budget': 15,
      'workweek': ['sat', 'sun'],
      'workweek_source': 'default',
      'results_by_length': {
        '5': [tripJson],
      },
    });
    expect(r.country, 'KR');
    expect(r.budget, 15);
    expect(r.workweekSource, 'default');
    expect(r.resultsByLength['5']!.single.breakLength, 5);
  });
}
