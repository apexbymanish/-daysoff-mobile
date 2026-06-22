import 'package:flutter/material.dart';
import '../../../api/models/plan_trip.dart';
import '../../../core/break_days.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

/// Option C — proportional colour bar (H / PTO / Weekend) with legend below.
/// Replaces the old H/P/W letter-tile row.
class DayRibbon extends StatelessWidget {
  const DayRibbon({super.key, required this.trip, this.barHeight = 20.0});
  final PlanTrip trip;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    final days = <DateTime>[];
    for (var d = trip.breakStart;
        !d.isAfter(trip.breakEnd);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    int hol = 0, pto = 0, wkd = 0;
    for (final d in days) {
      switch (classifyBreakDay(d, trip.ptoDates)) {
        case BreakDayKind.holiday:
          hol++;
        case BreakDayKind.pto:
          pto++;
        case BreakDayKind.weekend:
          wkd++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Proportional colour bar — flex values = day counts
        ClipRRect(
          borderRadius: BorderRadius.circular(barHeight <= 10 ? 4 : 8),
          child: SizedBox(
            height: barHeight,
            child: Row(
              children: [
                if (hol > 0)
                  Expanded(
                    flex: hol,
                    child: ColoredBox(color: DaysoffColors.holidaySurface),
                  ),
                if (pto > 0)
                  Expanded(
                    flex: pto,
                    child: ColoredBox(color: DaysoffColors.brandTeal),
                  ),
                if (wkd > 0)
                  Expanded(
                    flex: wkd,
                    child: const ColoredBox(color: Color(0xFFE5E7EB)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        Row(
          children: [
            if (hol > 0)
              _LegendDot(
                color: DaysoffColors.koreaRed.withValues(alpha: 0.6),
                label: '$hol hol',
              ),
            if (hol > 0 && pto > 0) const SizedBox(width: 12),
            if (pto > 0)
              _LegendDot(color: DaysoffColors.brandTeal, label: '$pto PTO'),
            if (wkd > 0) const SizedBox(width: 12),
            if (wkd > 0)
              _LegendDot(
                color: const Color(0xFFD1D5DB),
                label: '$wkd wkd',
              ),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: labelCaps(fontSize: 9, color: DaysoffColors.neutral500)),
      ],
    );
  }
}
