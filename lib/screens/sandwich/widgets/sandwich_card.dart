import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/models/sandwich_record.dart';
import '../../../api/models/saved_break.dart';
import '../../../providers/saved_breaks_provider.dart';
import '../../../theme/colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/typography.dart';

/// Redesigned 6.7 sandwich card: white tactile-card, day-ribbon, save button.
class SandwichCard extends ConsumerWidget {
  const SandwichCard({super.key, required this.record});
  final SandwichRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final dayFmt = DateFormat('MMM d');

    // The PTO days to take. Falls back to the single primary date for any
    // response that predates pto_dates.
    final ptoDays =
        record.ptoDates.isEmpty ? <DateTime>[record.ptoDate] : record.ptoDates;
    final ptoLabel = ptoDays.length == 1
        ? 'Take ${record.weekday} ${dayFmt.format(record.ptoDate)} off'
        : l.takeDaysOff(ptoDays.length);

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
      clipBehavior: Clip.antiAlias,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Day strip header — full-bleed, flush at top ────────────────
          SizedBox(
            height: 60,
            child: Row(
              children: [
                for (var i = 0; i < days.length; i++) ...[
                  if (i > 0) const SizedBox(width: 1),
                  Expanded(
                    child: _DayCell(
                      day: days[i],
                      isPto: isPtoDay(days[i]),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Card body ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row + pills on the same line
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        ptoLabel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: DaysoffColors.brandTeal,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Pill(
                          icon: Icons.beach_access,
                          label: l.daysValue(record.breakLength),
                          background: DaysoffColors.brandTeal,
                          foreground: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        _Pill(
                          icon: Icons.bolt,
                          label: '${record.ptoCost} PTO',
                          background: DaysoffColors.oliveFixed,
                          foreground: DaysoffColors.olive,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  record.context,
                  style: const TextStyle(
                    fontSize: 13,
                    color: DaysoffColors.neutral500,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Footer ───────────────────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: DaysoffColors.outlineVariant),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 14),
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
                          ref
                              .read(savedBreaksProvider.notifier)
                              .add(SavedBreak(
                                id:
                                    'sandwich-${record.ptoDate.toIso8601String()}',
                                label: '${record.weekday} sandwich',
                                start: record.breakStart,
                                end: record.breakEnd,
                                ptoCost: record.ptoCost,
                                kind: 'sandwich',
                              ));
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.saved)));
                        },
                        icon: const Icon(Icons.bookmark, size: 20),
                        label: Text(l.saveAndRemind),
                      ),
                    ],
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

/// Small rounded stat pill (icon + caps label) used in the card header.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: labelCaps(fontSize: 10, color: foreground),
          ),
        ],
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

    // Option C: solid fill, no border, no radius (outer ClipRRect handles shape)
    final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
    final Color bg;
    final Color fg;
    if (isPto) {
      bg = DaysoffColors.oliveFixed;   // #E0E7FF — indigo tint
      fg = DaysoffColors.brandTeal;    // #312E81
    } else if (isWeekend) {
      bg = const Color(0xFFF3F4F6);   // neutral gray
      fg = DaysoffColors.neutral700;
    } else {
      bg = DaysoffColors.holidaySurface; // #FEF2F2 — red tint
      fg = DaysoffColors.koreaRed;       // #991B1B
    }

    return ColoredBox(
      color: bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weekdayFmt.format(day).toUpperCase(),
            style: labelCaps(fontSize: 9, color: fg),
          ),
          const SizedBox(height: 2),
          Text(
            numFmt.format(day),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: fg,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
