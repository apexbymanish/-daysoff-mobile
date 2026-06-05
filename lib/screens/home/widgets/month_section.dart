import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

/// Month-group section header above a run of HolidayCards.
/// Matches Stitch 6.1: uppercase caps label + a horizontal divider line.
class MonthSection extends StatelessWidget {
  const MonthSection({super.key, required this.month});

  /// 1..12
  final int month;

  @override
  Widget build(BuildContext context) {
    final name = DateFormat('MMMM').format(DateTime(2000, month));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name.toUpperCase(),
            style: labelCaps(
              fontSize: 12,
              color: DaysoffColors.neutral700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              thickness: 1,
              color: const Color(0xFFC0C8C8).withValues(alpha: 0.3),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
