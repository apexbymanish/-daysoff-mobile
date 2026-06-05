import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/theme/app_theme.dart';
import 'package:daysoff_mobile/theme/typography.dart';

void main() {
  testWidgets('base text theme is Manrope', (tester) async {
    final f = DaysoffTheme.light().textTheme.bodyLarge!.fontFamily ?? '';
    expect(f.toLowerCase(), contains('manrope'));
  });
  test('labelCaps is JetBrains Mono', () {
    expect((labelCaps().fontFamily ?? '').toLowerCase(), contains('jetbrains'));
  });
}
