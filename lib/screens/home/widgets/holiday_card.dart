import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/models/holiday.dart';
import '../../../core/holiday_status.dart';
import '../../../providers/preferences_provider.dart';
import '../../../theme/colors.dart';

/// A single holiday row in the home timeline: date stack, the holiday name
/// (with its native-language name beneath when available), and a free/absorbed
/// badge based on the user's weekend.
class HolidayCard extends ConsumerWidget {
  const HolidayCard({super.key, required this.holiday});

  final Holiday holiday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekend = ref.watch(weekendProvider);
    final absorbed = isAbsorbed(holiday.date, weekend);
    final dayFmt = DateFormat('d');
    final dowFmt = DateFormat('EEE');
    final hasLocal =
        holiday.nameLocal != null && holiday.nameLocal != holiday.name;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DaysoffColors.neutral100, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayFmt.format(holiday.date),
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w600, height: 1.0),
                ),
                const SizedBox(height: 2),
                Text(
                  dowFmt.format(holiday.date).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11,
                      color: DaysoffColors.neutral500,
                      letterSpacing: 0.8),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
                if (hasLocal) ...[
                  const SizedBox(height: 2),
                  Text(
                    holiday.nameLocal!,
                    style: const TextStyle(
                        fontSize: 12, color: DaysoffColors.neutral500),
                  ),
                ],
              ],
            ),
          ),
          _StatusBadge(absorbed: absorbed),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.absorbed});
  final bool absorbed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          absorbed ? Icons.nightlight_round : Icons.wb_sunny_outlined,
          size: 14,
          color: absorbed ? DaysoffColors.neutral500 : DaysoffColors.peachDark,
        ),
        const SizedBox(width: 4),
        Text(
          absorbed ? 'absorbed' : 'free',
          style: TextStyle(
            fontSize: 11,
            color: absorbed ? DaysoffColors.neutral500 : DaysoffColors.peachDark,
          ),
        ),
      ],
    );
  }
}
