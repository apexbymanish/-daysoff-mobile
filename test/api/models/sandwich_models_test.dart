import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/sandwich_record.dart';
import 'package:daysoff_mobile/api/models/sandwiches_response.dart';

void main() {
  const recJson = {
    'pto_date': '2026-05-04',
    'weekday': 'Monday',
    'break_start': '2026-05-02',
    'break_end': '2026-05-05',
    'break_length': 4,
    'pto_cost': 1,
    'context': 'Weekend + Children\'s Day',
  };

  test('SandwichRecord.fromJson maps snake_case + dates', () {
    final r = SandwichRecord.fromJson(recJson);
    expect(r.ptoDate, DateTime(2026, 5, 4));
    expect(r.weekday, 'Monday');
    expect(r.breakStart, DateTime(2026, 5, 2));
    expect(r.breakEnd, DateTime(2026, 5, 5));
    expect(r.breakLength, 4);
    expect(r.ptoCost, 1);
    expect(r.context, "Weekend + Children's Day");
  });

  test('SandwichesResponse.fromJson parses list + workweek', () {
    final resp = SandwichesResponse.fromJson({
      'country': 'KR',
      'year': 2026,
      'workweek': ['sat', 'sun'],
      'workweek_source': 'default',
      'count': 1,
      'sandwiches': [recJson],
    });
    expect(resp.country, 'KR');
    expect(resp.workweekSource, 'default');
    expect(resp.count, 1);
    expect(resp.sandwiches.single.ptoDate, DateTime(2026, 5, 4));
  });
}
