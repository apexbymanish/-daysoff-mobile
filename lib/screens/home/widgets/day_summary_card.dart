import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../api/models/holiday.dart';
import '../../../core/holiday_status.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

/// Inline card shown below the calendar legend displaying the currently
/// selected day's holiday (if any) or a "nothing on this day" placeholder.
class DaySummaryCard extends StatelessWidget {
  const DaySummaryCard({
    super.key,
    required this.day,
    required this.holiday,
    required this.weekend,
  });

  final DateTime day;
  final Holiday? holiday;

  /// Weekend tokens (e.g. ['sat', 'sun']) — used to compute free vs. absorbed.
  final List<String> weekend;

  @override
  Widget build(BuildContext context) {
    final h = holiday;
    if (h == null) {
      return _NoHolidayCard(day: day);
    }
    final absorbed = isAbsorbed(day, weekend);
    return _HolidayCard(day: day, holiday: h, absorbed: absorbed);
  }
}

// ─── Holiday variant ─────────────────────────────────────────────────────────

class _HolidayCard extends StatelessWidget {
  const _HolidayCard({
    required this.day,
    required this.holiday,
    required this.absorbed,
  });

  final DateTime day;
  final Holiday holiday;
  final bool absorbed;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${DateFormat('EEE MMM d').format(day)} · Public Holiday';
    final showLocal = holiday.nameLocal != null &&
        holiday.nameLocal!.isNotEmpty &&
        holiday.nameLocal != holiday.name;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: DaysoffColors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left icon square
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DaysoffColors.brandTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.wb_sunny,
              color: DaysoffColors.brandTeal,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          // Right content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name row + pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _HolidayName(
                          name: holiday.name,
                          nameLocal: showLocal ? holiday.nameLocal : null),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(absorbed: absorbed),
                  ],
                ),
                const SizedBox(height: 4),
                // Date row
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: DaysoffColors.neutral500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dateLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          color: DaysoffColors.neutral700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HolidayName extends StatelessWidget {
  const _HolidayName({required this.name, this.nameLocal});

  final String name;
  final String? nameLocal;

  @override
  Widget build(BuildContext context) {
    if (nameLocal == null) {
      return Text(
        name,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: DaysoffColors.neutral900,
        ),
      );
    }
    // Use separate Text widgets so tests can find both strings.
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$name / ',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: DaysoffColors.neutral900,
          ),
        ),
        Text(
          nameLocal!,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: DaysoffColors.neutral500,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.absorbed});

  final bool absorbed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: absorbed
            ? DaysoffColors.surfaceVariant
            : DaysoffColors.oliveFixed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        absorbed ? 'ABSORBED' : 'FREE DAY',
        style: labelCaps(
          fontSize: 10,
          color: absorbed ? DaysoffColors.neutral700 : DaysoffColors.olive,
        ),
      ),
    );
  }
}

// ─── No-holiday variant ───────────────────────────────────────────────────────

class _NoHolidayCard extends StatelessWidget {
  const _NoHolidayCard({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE MMM d').format(day);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: DaysoffColors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: DaysoffColors.neutral900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nothing on this day.',
            style: TextStyle(
              fontSize: 14,
              color: DaysoffColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}
