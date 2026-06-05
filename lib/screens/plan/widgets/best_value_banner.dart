import 'package:flutter/material.dart';
import '../../../api/models/plan_trip.dart';
import '../../../theme/colors.dart';

/// Olive-tinted callout highlighting the best-value break.
class BestValueBanner extends StatelessWidget {
  const BestValueBanner({super.key, required this.trip});
  final PlanTrip trip;

  @override
  Widget build(BuildContext context) {
    final ptoCost = trip.ptoCost;
    final unit = ptoCost == 1 ? 'PTO day' : 'PTO days';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: DaysoffColors.oliveFixed,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // White circle with auto_awesome icon
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 20,
              color: DaysoffColors.olive,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Best value found',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DaysoffColors.olive,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trip.breakLength}-day break for just $ptoCost $unit',
                  style: TextStyle(
                    fontSize: 14,
                    color: DaysoffColors.olive.withValues(alpha: 0.8),
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
