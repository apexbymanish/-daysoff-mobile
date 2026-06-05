import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/preferences_provider.dart';
import '../theme/colors.dart';

/// Shows the shared preference editor as a modal bottom sheet.
Future<void> showPreferencesEditor(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: PreferencesEditorSheet(),
    ),
  );
}

/// Editor for PTO budget, break-length range and weekend (days off).
/// Each control writes to its provider immediately.
class PreferencesEditorSheet extends ConsumerWidget {
  const PreferencesEditorSheet({super.key});

  static const _minLen = 2;
  static const _maxLen = 21;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(ptoBudgetProvider);
    final range = ref.watch(breakLengthProvider);
    final weekend = ref.watch(weekendProvider);

    return SafeArea(
      top: false,
      child: ListView(
        shrinkWrap: true,
        children: [
          const _Label('PTO budget'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                key: const Key('budget_dec'),
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: budget > 0
                    ? () => ref.read(ptoBudgetProvider.notifier).state = budget - 1
                    : null,
              ),
              Text('$budget days',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              IconButton(
                key: const Key('budget_inc'),
                icon: const Icon(Icons.add_circle_outline),
                onPressed: budget < 40
                    ? () => ref.read(ptoBudgetProvider.notifier).state = budget + 1
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Label('Break length  (${range.min}–${range.max} days)'),
          RangeSlider(
            min: _minLen.toDouble(),
            max: _maxLen.toDouble(),
            divisions: _maxLen - _minLen,
            labels: RangeLabels('${range.min}', '${range.max}'),
            values: RangeValues(range.min.toDouble(), range.max.toDouble()),
            onChanged: (v) {
              var lo = v.start.round();
              var hi = v.end.round();
              if (lo > hi) lo = hi;
              ref.read(breakLengthProvider.notifier).state =
                  BreakLengthRange(min: lo, max: hi);
            },
          ),
          const SizedBox(height: 8),
          const _Label('Weekend (days off)'),
          Wrap(
            spacing: 8,
            children: [
              for (final key in kWeekdayKeys)
                FilterChip(
                  label: Text(kWeekdayLabels[key]!),
                  selected: weekend.contains(key),
                  onSelected: (sel) {
                    final next = [...weekend];
                    if (sel) {
                      if (next.length >= 6) return;
                      if (!next.contains(key)) next.add(key);
                    } else {
                      if (next.length <= 1) return;
                      next.remove(key);
                    }
                    ref.read(weekendProvider.notifier).state = next;
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DaysoffColors.neutral700)),
    );
  }
}
