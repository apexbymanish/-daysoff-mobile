import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../api/models/holiday.dart';
import '../../../theme/colors.dart';
import 'scenery.dart';

/// Scenery "next break" hero card for the top of the Holidays list.
class NextBreakHero extends StatelessWidget {
  const NextBreakHero({super.key, required this.next, this.onSeeDetails});

  final Holiday next;
  final VoidCallback? onSeeDetails;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = next.date.difference(today).inDays;
    final dateFmt = DateFormat('EEE, MMM d');
    final hasLocal = next.nameLocal != null && next.nameLocal != next.name;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      height: 188,
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
          Image.asset(
            sceneryForDate(next.date),
            fit: BoxFit.cover,
            errorBuilder: (_, e, st) => const SizedBox.shrink(),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEXT BREAK IN',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                    const Text('days',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hasLocal ? '${next.name}  ·  ${next.nameLocal}' : next.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  dateFmt.format(next.date),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (onSeeDetails != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: TextButton(
                onPressed: onSeeDetails,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('See details'),
              ),
            ),
        ],
      ),
    );
  }
}
