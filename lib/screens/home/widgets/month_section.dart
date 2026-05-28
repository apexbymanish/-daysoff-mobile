import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/colors.dart';

/// Month-group section header above a run of HolidayCards.
class MonthSection extends StatelessWidget {
  const MonthSection({super.key, required this.month});

  /// 1..12
  final int month;

  @override
  Widget build(BuildContext context) {
    final name = DateFormat('MMMM').format(DateTime(2000, month));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: DaysoffColors.neutral900,
            ),
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: DaysoffColors.neutral100),
        ],
      ),
    );
  }
}
