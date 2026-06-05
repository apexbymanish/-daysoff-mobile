import 'package:flutter/material.dart';
import '../../../api/models/plan_trip.dart';
import '../../../core/break_days.dart';
import '../../../theme/colors.dart';

/// A row of large ribbon blocks, one per break day.
/// H (holiday) = indigo, P (PTO) = olive, W (weekend) = gray.
class DayRibbon extends StatelessWidget {
  const DayRibbon({super.key, required this.trip});
  final PlanTrip trip;

  ({String label, Color bg, Color fg}) _block(DateTime day) =>
      switch (classifyBreakDay(day, trip.ptoDates)) {
        BreakDayKind.holiday => (
            label: 'H',
            bg: DaysoffColors.indigoContainer.withValues(alpha: 0.35),
            fg: DaysoffColors.indigo,
          ),
        BreakDayKind.pto => (
            label: 'P',
            bg: DaysoffColors.oliveFixed,
            fg: DaysoffColors.olive,
          ),
        BreakDayKind.weekend => (
            label: 'W',
            bg: DaysoffColors.surfaceContainerHigh,
            fg: DaysoffColors.neutral700,
          ),
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
        for (var i = 0; i < days.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Builder(builder: (_) {
              final b = _block(days[i]);
              return Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: b.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  b.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: b.fg,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
