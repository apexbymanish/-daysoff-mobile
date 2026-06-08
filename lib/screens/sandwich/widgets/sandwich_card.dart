import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/models/sandwich_record.dart';
import '../../../api/models/saved_break.dart';
import '../../../providers/saved_breaks_provider.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

/// Redesigned 6.7 sandwich card: white tactile-card, day-ribbon, save button.
class SandwichCard extends ConsumerWidget {
  const SandwichCard({super.key, required this.record});
  final SandwichRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayFmt = DateFormat('MMM d');

    // The PTO days to take. Falls back to the single primary date for any
    // response that predates pto_dates.
    final ptoDays =
        record.ptoDates.isEmpty ? <DateTime>[record.ptoDate] : record.ptoDates;
    final ptoLabel = ptoDays.length == 1
        ? 'Take ${record.weekday} ${dayFmt.format(record.ptoDate)} off'
        : 'Take ${ptoDays.length} days off';

    bool isPtoDay(DateTime d) => ptoDays.any((p) =>
        p.year == d.year && p.month == d.month && p.day == d.day);

    // Build day cells from breakStart..breakEnd inclusive
    final days = <DateTime>[];
    for (var d = record.breakStart;
        !d.isAfter(record.breakEnd);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DaysoffColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.today,
                              color: DaysoffColors.brandTeal, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ptoLabel,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: DaysoffColors.brandTeal,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.context,
                        style: const TextStyle(
                          fontSize: 14,
                          color: DaysoffColors.neutral700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Olive PTO pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: DaysoffColors.oliveFixed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt,
                          size: 14, color: DaysoffColors.olive),
                      const SizedBox(width: 4),
                      Text(
                        '${record.ptoCost} PTO',
                        style: labelCaps(
                          fontSize: 10,
                          color: DaysoffColors.olive,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Day ribbon ──────────────────────────────────────────────────
            Row(
              children: [
                for (var i = 0; i < days.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                      child: _DayCell(day: days[i], isPto: isPtoDay(days[i]))),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // ── Footer ──────────────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: DaysoffColors.outlineVariant),
                ),
              ),
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 18, color: DaysoffColors.neutral700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.context.toUpperCase(),
                      style: labelCaps(
                        fontSize: 11,
                        color: DaysoffColors.neutral700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: DaysoffColors.brandTeal,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onPressed: () {
                      ref.read(savedBreaksProvider.notifier).add(SavedBreak(
                            id: 'sandwich-${record.ptoDate.toIso8601String()}',
                            label: '${record.weekday} sandwich',
                            start: record.breakStart,
                            end: record.breakEnd,
                            ptoCost: record.ptoCost,
                            kind: 'sandwich',
                          ));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved')));
                    },
                    icon: const Icon(Icons.bookmark, size: 20),
                    label: const Text('Save + remind'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isPto});
  final DateTime day;
  final bool isPto;

  @override
  Widget build(BuildContext context) {
    final weekdayFmt = DateFormat('EEE');
    final numFmt = DateFormat('d');

    final bgColor = isPto
        ? DaysoffColors.brandTeal.withValues(alpha: 0.06)
        : const Color(0xFFEDEEED).withValues(alpha: 0.5);
    final borderColor =
        isPto ? DaysoffColors.brandTeal : DaysoffColors.outlineVariant;
    final borderWidth = isPto ? 2.0 : 1.0;
    final textColor =
        isPto ? DaysoffColors.brandTeal : DaysoffColors.neutral700;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weekdayFmt.format(day).toUpperCase(),
            style: labelCaps(fontSize: 10, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            numFmt.format(day),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
