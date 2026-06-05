import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage_io.dart';
import '../core/storage_keys.dart';

/// Day-of-week keys in week order; values match the API's workweek tokens.
const kWeekdayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
const kWeekdayLabels = {
  'mon': 'Mon', 'tue': 'Tue', 'wed': 'Wed', 'thu': 'Thu',
  'fri': 'Fri', 'sat': 'Sat', 'sun': 'Sun',
};

/// "Sat, Sun" — week-ordered, ignoring the stored order.
String formatWeekend(List<String> days) =>
    kWeekdayKeys.where(days.contains).map((d) => kWeekdayLabels[d]!).join(', ');

/// Inclusive min/max break length (days) for the plan buffet.
class BreakLengthRange {
  const BreakLengthRange({required this.min, required this.max});
  final int min;
  final int max;

  BreakLengthRange copyWith({int? min, int? max}) =>
      BreakLengthRange(min: min ?? this.min, max: max ?? this.max);

  @override
  bool operator ==(Object other) =>
      other is BreakLengthRange && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);
}

final ptoBudgetProvider = StateProvider<int>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) => storageWrite(StorageKeys.ptoBudget, next));
  return storageRead<int>(StorageKeys.ptoBudget) ?? 15;
});

final breakLengthProvider = StateProvider<BreakLengthRange>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) {
    storageWrite(StorageKeys.breakMin, next.min);
    storageWrite(StorageKeys.breakMax, next.max);
  });
  return BreakLengthRange(
    min: storageRead<int>(StorageKeys.breakMin) ?? 3,
    max: storageRead<int>(StorageKeys.breakMax) ?? 10,
  );
});

final weekendProvider = StateProvider<List<String>>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) => storageWrite(StorageKeys.weekend, next));
  final stored = storageRead<List>(StorageKeys.weekend);
  return stored?.cast<String>() ?? const ['sat', 'sun'];
});
