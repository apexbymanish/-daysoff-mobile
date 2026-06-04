import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

class PtoCostPill extends StatelessWidget {
  const PtoCostPill({super.key, required this.cost});
  final int cost;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    if (cost == 0) {
      bg = DaysoffColors.peach;
    } else if (cost <= 2) {
      bg = DaysoffColors.sage;
    } else {
      bg = DaysoffColors.neutral300;
    }
    final label = cost == 0 ? 'Free' : '$cost PTO';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: DaysoffColors.neutral900)),
    );
  }
}
