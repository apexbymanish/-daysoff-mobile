import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/screens/home/widgets/scenery.dart';

void main() {
  test('sceneryForDate returns a path from kScenery', () {
    expect(kScenery, contains(sceneryForDate(DateTime(2026, 5, 5))));
  });

  test('sceneryForDate is deterministic for a fixed date', () {
    expect(sceneryForDate(DateTime(2026, 5, 5)), sceneryForDate(DateTime(2026, 5, 5)));
  });
}
