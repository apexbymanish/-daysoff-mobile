import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/providers/holidays_view_provider.dart';

void main() {
  test('default view is list', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(holidaysViewProvider), HolidaysView.list);
  });
}
