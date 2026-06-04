import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/saved_break.dart';
import 'package:daysoff_mobile/providers/saved_breaks_provider.dart';

SavedBreak _b(String id) => SavedBreak(
      id: id,
      label: '5-day break',
      start: DateTime(2026, 9, 23),
      end: DateTime(2026, 9, 27),
      ptoCost: 1,
      kind: 'break',
    );

void main() {
  test('starts empty, add then remove (in-memory; storage no-op in tests)', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(savedBreaksProvider), isEmpty);

    c.read(savedBreaksProvider.notifier).add(_b('break-1'));
    expect(c.read(savedBreaksProvider).map((e) => e.id), ['break-1']);

    // de-dupes by id
    c.read(savedBreaksProvider.notifier).add(_b('break-1'));
    expect(c.read(savedBreaksProvider).length, 1);

    c.read(savedBreaksProvider.notifier).remove('break-1');
    expect(c.read(savedBreaksProvider), isEmpty);
  });

  test('SavedBreak JSON round-trips', () {
    final b = _b('x');
    expect(SavedBreak.fromJson(b.toJson()).id, 'x');
    expect(SavedBreak.fromJson(b.toJson()).start, DateTime(2026, 9, 23));
  });
}
