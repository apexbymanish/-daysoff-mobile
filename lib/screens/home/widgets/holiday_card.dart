import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../api/models/holiday.dart';
import '../../../theme/colors.dart';

/// A single holiday row in the home timeline.
///
/// Shows a left date stack (day numeral + weekday) and the holiday name,
/// plus a small "free" / "absorbed" badge depending on whether the date
/// falls on a weekend (Sat/Sun, assumed for KR per master.md fallback).
class HolidayCard extends StatelessWidget {
  const HolidayCard({super.key, required this.holiday});

  final Holiday holiday;

  bool get _isAbsorbed =>
      holiday.date.weekday == DateTime.saturday ||
      holiday.date.weekday == DateTime.sunday;

  @override
  Widget build(BuildContext context) {
    final dayFmt = DateFormat('d');
    final dowFmt = DateFormat('EEE');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DaysoffColors.neutral100, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayFmt.format(holiday.date),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dowFmt.format(holiday.date).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: DaysoffColors.neutral500,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              holiday.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          _StatusBadge(absorbed: _isAbsorbed),
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
