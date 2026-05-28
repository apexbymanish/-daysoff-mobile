import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../api/models/holiday.dart';
import '../../../theme/colors.dart';

/// "17 days until Children's Day" hero strip.
class DaysUntilBanner extends StatelessWidget {
  const DaysUntilBanner({super.key, required this.next});

  final Holiday next;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = next.date.difference(today).inDays;
    final dateFmt = DateFormat('EEE, MMM d');

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DaysoffColors.peach.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            days.toString(),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              height: 1.0,
              color: DaysoffColors.brandTeal,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'days until',
                  style: TextStyle(fontSize: 12, color: DaysoffColors.neutral700),
                ),
                Text(
                  next.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dateFmt.format(next.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: DaysoffColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
