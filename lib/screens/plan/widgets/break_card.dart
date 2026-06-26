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

    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
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
          clipBehavior: Clip.hardEdge,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Split stat row ──────────────────────────────────
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left: days off + date range
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 14, 20),
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
                                      fontWeight: FontWeight.w900,
                                      color: DaysoffColors.brandTeal,
                                      letterSpacing: -1,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'days',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: DaysoffColors.brandTeal,
                                          height: 1.2,
                                        ),
                                      ),
                                      Text(
                                        'off',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: DaysoffColors.brandTeal,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                range,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: DaysoffColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Vertical divider
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                      // Right: PTO cost
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 24, 24, 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${trip.ptoCost}',
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: DaysoffColors.brandTeal,
                                  letterSpacing: -1,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'PTO USED',
                                style: labelCaps(
                                  fontSize: 10,
                                  color: DaysoffColors.neutral500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'days',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: DaysoffColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Thin ribbon + footer ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DayRibbon(trip: trip, barHeight: 8),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 20,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                anchor,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isBestValue && onTap != null)
                              TextButton(
                                onPressed: onTap,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: const Size(44, 44),
                                ),
                                child: const Text(
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
              ],
            ),
            // "BEST VALUE" rotated badge
            if (isBestValue) const _BestValueBadge(),
          ],
        ),
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
              color: const Color(0xFFB8C5FF), // primary-fixed tint (indigo)
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
