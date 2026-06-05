import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../api/models/plan_trip.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import 'day_ribbon.dart';

/// Carousel card for a single break option.
///
/// [isBestValue] adds a 2 px [DaysoffColors.brandTeal] border + a rotated
/// "BEST VALUE" badge and a "Details ›" button.
class BreakCard extends StatelessWidget {
  const BreakCard({
    super.key,
    required this.trip,
    this.onTap,
    this.isBestValue = false,
  });

  final PlanTrip trip;
  final VoidCallback? onTap;
  final bool isBestValue;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d');
    final range = '${fmt.format(trip.breakStart)} – ${fmt.format(trip.breakEnd)}';
    final anchor = trip.anchors.isNotEmpty ? trip.anchors.first : '';

    final borderColor =
        isBestValue ? DaysoffColors.brandTeal : DaysoffColors.outlineVariant;
    final borderWidth = isBestValue ? 2.0 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: DaysoffColors.brandTeal.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: numeral + PTO pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Numeral + "days" + date range
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${trip.breakLength}',
                                  style: const TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w700,
                                    color: DaysoffColors.brandTeal,
                                    letterSpacing: -1,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'days',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: DaysoffColors.brandTeal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              range,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: DaysoffColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // PTO used pill
                      _PtoPill(ptoCost: trip.ptoCost),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Ribbon blocks
                  DayRibbon(trip: trip),
                  const SizedBox(height: 20),
                  // Footer
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: DaysoffColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.flag_outlined,
                          size: 20,
                          color: DaysoffColors.neutral700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            anchor,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: DaysoffColors.neutral700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isBestValue && onTap != null)
                          TextButton(
                            onPressed: onTap,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Details ›',
                              style: TextStyle(
                                color: DaysoffColors.brandTeal,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // "BEST VALUE" rotated badge
            if (isBestValue) const _BestValueBadge(),
          ],
        ),
      ),
    );
  }
}

class _PtoPill extends StatelessWidget {
  const _PtoPill({required this.ptoCost});
  final int ptoCost;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;
    if (ptoCost == 0) {
      bg = DaysoffColors.redContainer;
      fg = DaysoffColors.onRedContainer;
      label = '0 PTO USED';
    } else {
      bg = DaysoffColors.oliveFixed;
      fg = DaysoffColors.olive;
      label = '$ptoCost PTO USED';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: labelCaps(fontSize: 10, color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _BestValueBadge extends StatelessWidget {
  const _BestValueBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: -40,
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: 130,
          padding: const EdgeInsets.symmetric(vertical: 6),
          color: DaysoffColors.brandTeal,
          alignment: Alignment.center,
          child: Text(
            'BEST VALUE',
            style: labelCaps(
              fontSize: 10,
              color: const Color(0xFFBAECEC), // primary-fixed / cream
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
