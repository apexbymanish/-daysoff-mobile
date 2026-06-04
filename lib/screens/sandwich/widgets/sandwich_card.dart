import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../api/models/sandwich_record.dart';
import '../../../theme/colors.dart';
import '../../plan/widgets/pto_cost_pill.dart';

/// A single sandwich-day suggestion. Outlined card (dashed-border styling is
/// a future cosmetic enhancement) with a one-tap "save" affordance.
class SandwichCard extends StatelessWidget {
  const SandwichCard({super.key, required this.record});
  final SandwichRecord record;

  @override
  Widget build(BuildContext context) {
    final dayFmt = DateFormat('MMM d');
    final ptoLabel = '${record.weekday} ${dayFmt.format(record.ptoDate)}';
    final range = '${dayFmt.format(record.breakStart)}–${dayFmt.format(record.breakEnd)}';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DaysoffColors.creamSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DaysoffColors.sage, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text('Take $ptoLabel off',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600)),
              ),
              PtoCostPill(cost: record.ptoCost),
            ],
          ),
          const SizedBox(height: 6),
          Text('${record.context} → ${record.breakLength}-day break ($range)',
              style: const TextStyle(
                  fontSize: 13, color: DaysoffColors.neutral700)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {}, // save + remind: wired in a later phase
              icon: const Icon(Icons.bookmark_border, size: 18),
              label: const Text('Save + remind'),
            ),
          ),
        ],
      ),
    );
  }
}
