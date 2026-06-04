import 'package:flutter/material.dart';
import '../../../api/models/plan_trip.dart';
import '../../../core/break_days.dart';
import '../../../theme/colors.dart';

/// A horizontal strip of colored blocks, one per day of the break.
/// Within a break every day is off — classify as PTO, weekend, or holiday
/// (a day that is neither PTO nor weekend must be the anchoring holiday).
class DayRibbon extends StatelessWidget {
  const DayRibbon({super.key, required this.trip});
  final PlanTrip trip;

  Color _colorFor(DateTime day) => switch (classifyBreakDay(day, trip.ptoDates)) {
        BreakDayKind.pto => DaysoffColors.sage,
        BreakDayKind.weekend => DaysoffColors.brandTeal,
        BreakDayKind.holiday => DaysoffColors.peach,
      };

  @override
  Widget build(BuildContext context) {
    final days = <DateTime>[];
    for (var d = trip.breakStart;
        !d.isAfter(trip.breakEnd);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return SizedBox(
      height: 10,
      child: Row(
        children: [
          for (final d in days)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: _colorFor(d),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
