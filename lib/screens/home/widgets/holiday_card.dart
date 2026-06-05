import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/models/holiday.dart';
import '../../../core/holiday_status.dart';
import '../../../providers/preferences_provider.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

/// A single holiday card in the home timeline.
/// White, outline-variant bordered, rounded-16 container with internal padding.
/// Row: date numeral (teal) + weekday | holiday name + native subtitle | status pill.
class HolidayCard extends ConsumerWidget {
  const HolidayCard({super.key, required this.holiday, this.onTap});

  final Holiday holiday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekend = ref.watch(weekendProvider);
    final absorbed = isAbsorbed(holiday.date, weekend);
    final dayFmt = DateFormat('d');
    final dowFmt = DateFormat('EEE');
    final hasLocal =
        holiday.nameLocal != null && holiday.nameLocal != holiday.name;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC0C8C8), // outline-variant
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date column: numeral + weekday
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayFmt.format(holiday.date),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        color: absorbed
                            ? DaysoffColors.neutral700.withValues(alpha: 0.5)
                            : DaysoffColors.brandTeal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dowFmt.format(holiday.date).toUpperCase(),
                      style: labelCaps(
                        fontSize: 10,
                        color: DaysoffColors.neutral700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              // Left divider
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: const Color(0xFFC0C8C8).withValues(alpha: 0.5),
              ),
              // Name + native subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holiday.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: DaysoffColors.neutral900,
                      ),
                    ),
                    if (hasLocal) ...[
                      const SizedBox(height: 2),
                      Text(
                        holiday.nameLocal!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: DaysoffColors.neutral700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status pill
              _StatusPill(absorbed: absorbed),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.absorbed});
  final bool absorbed;

  @override
  Widget build(BuildContext context) {
    if (absorbed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE7E8E8),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bedtime,
              size: 14,
              color: DaysoffColors.neutral700.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              'Absorbed',
              style: labelCaps(
                fontSize: 10,
                color: DaysoffColors.neutral700.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: DaysoffColors.brandTeal.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wb_sunny,
              size: 14,
              color: DaysoffColors.brandTeal,
            ),
            const SizedBox(width: 4),
            Text(
              'Free',
              style: labelCaps(
                fontSize: 10,
                color: DaysoffColors.brandTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
  }
}
