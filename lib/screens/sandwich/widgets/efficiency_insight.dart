import 'dart:math';
import 'package:flutter/material.dart';

import '../../../api/models/sandwich_record.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

/// Efficiency insight card shown below the list of sandwich cards.
/// Returns [SizedBox.shrink] when [records] is empty.
class EfficiencyInsight extends StatelessWidget {
  const EfficiencyInsight({super.key, required this.records});
  final List<SandwichRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return const SizedBox.shrink();

    final totalBreakDays = records.fold<int>(0, (s, r) => s + r.breakLength);
    final totalPto = records.fold<int>(0, (s, r) => s + r.ptoCost);
    final ratio = (totalBreakDays / max(totalPto, 1)).round();
    final barValue = min(ratio / 5.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DaysoffColors.brandTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: DaysoffColors.brandTeal.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.analytics,
                  color: DaysoffColors.brandTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'EFFICIENCY INSIGHT',
                style: labelCaps(
                  fontSize: 12,
                  color: DaysoffColors.brandTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar + ratio
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: barValue,
                    backgroundColor:
                        DaysoffColors.brandTeal.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        DaysoffColors.brandTeal),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$ratio:1',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: DaysoffColors.brandTeal,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Copy
          Text(
            'Your rest efficiency is high: 1 PTO day consumed for every $ratio consecutive days of rest.',
            style: const TextStyle(
              fontSize: 14,
              color: DaysoffColors.neutral700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
