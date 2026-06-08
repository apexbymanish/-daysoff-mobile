import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/plan_view_provider.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

/// A horizontally-scrollable chip row for filtering the Plan screen by month.
///
/// Shows "All" + Jan … Dec. The selected chip is filled with
/// [DaysoffColors.brandTeal]; unselected chips are white with an
/// [DaysoffColors.outlineVariant] border. Labels are rendered via [labelCaps].
///
/// Tapping "All" sets [planMonthProvider] to null; tapping a month sets it to
/// 1–12.
class MonthStrip extends ConsumerWidget {
  const MonthStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(planMonthProvider);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          _MonthChip(
            key: const Key('month-all'),
            label: 'All',
            isSelected: selected == null,
            onTap: () => ref.read(planMonthProvider.notifier).state = null,
          ),
          for (int m = 1; m <= 12; m++)
            _MonthChip(
              key: Key('month-$m'),
              label: DateFormat('MMM').format(DateTime(2000, m)).toUpperCase(),
              isSelected: selected == m,
              onTap: () => ref.read(planMonthProvider.notifier).state = m,
            ),
        ],
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? DaysoffColors.brandTeal : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? DaysoffColors.brandTeal
                  : DaysoffColors.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: labelCaps(
              fontSize: 11,
              color: isSelected ? Colors.white : DaysoffColors.neutral700,
            ),
          ),
        ),
      ),
    );
  }
}
