import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../api/models/holiday.dart';
import '../../../theme/colors.dart';
import 'scenery.dart';

/// Scenery "next break" hero card for the top of the Holidays list.
/// Matches the Stitch 6.1 design: 240px height, bottom-left text overlay,
/// bottom-right translucent "See details" pill.
class NextBreakHero extends StatelessWidget {
  const NextBreakHero({super.key, required this.next, this.onSeeDetails});

  final Holiday next;
  final VoidCallback? onSeeDetails;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = next.date.difference(today).inDays;
    final dateFmt = DateFormat('MMM d');

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      height: 240,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DaysoffColors.brandTeal, DaysoffColors.sage],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Scenery image
          Image.asset(
            sceneryForDate(next.date),
            fit: BoxFit.cover,
            errorBuilder: (_, e, st) => const SizedBox.shrink(),
          ),
          // Bottom-up scrim: opaque at bottom, transparent at ~60% up
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 0.6],
                colors: [
                  Color(0x99000000), // ~60% black
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Bottom overlay: text left + pill right
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left: NEXT BREAK IN label + day count + name·date
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NEXT BREAK IN',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$days',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Days',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                next.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              ' · ${dateFmt.format(next.date)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Right: "See details" translucent pill
                  if (onSeeDetails != null)
                    TextButton(
                      onPressed: onSeeDetails,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'See details',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
