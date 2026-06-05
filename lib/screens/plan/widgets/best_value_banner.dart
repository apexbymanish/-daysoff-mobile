import 'package:flutter/material.dart';
import '../../../api/models/plan_trip.dart';
import '../../../theme/colors.dart';

/// Sage callout highlighting the best-value break.
class BestValueBanner extends StatelessWidget {
  const BestValueBanner({super.key, required this.trip});
  final PlanTrip trip;

  @override
  Widget build(BuildContext context) {
    final pto = trip.ptoCost == 0 ? 'no' : '${trip.ptoCost}';
    final unit = trip.ptoCost == 1 ? 'PTO day' : 'PTO days';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DaysoffColors.sage.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 18, color: DaysoffColors.brandTeal),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Best value found',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Text('${trip.breakLength}-day break for $pto $unit',
                    style: const TextStyle(
                        fontSize: 13, color: DaysoffColors.neutral700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
