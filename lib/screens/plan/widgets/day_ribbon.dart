import 'package:flutter/material.dart';
import '../../../api/models/plan_trip.dart';
import '../../../core/break_days.dart';
import '../../../theme/colors.dart';

/// A row of small letter pills, one per break day: P (PTO), W (weekend),
/// H (the anchoring holiday).
class DayRibbon extends StatelessWidget {
  const DayRibbon({super.key, required this.trip});
  final PlanTrip trip;

  ({String label, Color color}) _pill(DateTime day) =>
      switch (classifyBreakDay(day, trip.ptoDates)) {
        BreakDayKind.pto => (label: 'P', color: DaysoffColors.sage),
        BreakDayKind.weekend => (label: 'W', color: DaysoffColors.brandTeal),
        BreakDayKind.holiday => (label: 'H', color: DaysoffColors.peach),
      };

  @override
  Widget build(BuildContext context) {
    final days = <DateTime>[];
    for (var d = trip.breakStart;
        !d.isAfter(trip.breakEnd);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return Row(
      children: [
        for (final d in days)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Builder(builder: (_) {
              final p = _pill(d);
              return Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.color.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(p.label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DaysoffColors.neutral900)),
              );
            }),
          ),
      ],
    );
  }
}
