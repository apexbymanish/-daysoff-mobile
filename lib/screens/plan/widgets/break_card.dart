import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../api/models/plan_trip.dart';
import '../../../theme/colors.dart';
import 'day_ribbon.dart';
import 'pto_cost_pill.dart';

class BreakCard extends StatelessWidget {
  const BreakCard({super.key, required this.trip, required this.onTap});
  final PlanTrip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d');
    final range = '${fmt.format(trip.breakStart)} – ${fmt.format(trip.breakEnd)}';
    final anchor = trip.anchors.isNotEmpty ? trip.anchors.first : '';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DaysoffColors.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DaysoffColors.neutral300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${trip.breakLength} days',
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(range,
                          style: const TextStyle(
                              fontSize: 13, color: DaysoffColors.neutral700)),
                    ],
                  ),
                ),
                PtoCostPill(cost: trip.ptoCost),
              ],
            ),
            const SizedBox(height: 12),
            DayRibbon(trip: trip),
            const SizedBox(height: 12),
            Text('Anchored on $anchor',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: DaysoffColors.brandTeal)),
          ],
        ),
      ),
    );
  }
}
