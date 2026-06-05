import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../api/models/holiday.dart';
import '../../../api/models/saved_break.dart';
import '../../../theme/colors.dart';

/// Bottom sheet describing a single calendar day: its holiday(s) and any
/// saved break covering it.
Future<void> showDayDetailSheet(
  BuildContext context,
  DateTime day,
  List<Holiday> holidays,
  SavedBreak? savedBreak,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('EEEE, MMMM d, y').format(day),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (holidays.isEmpty && savedBreak == null)
              const Text('Nothing on this day.',
                  style: TextStyle(color: DaysoffColors.neutral700)),
            for (final h in holidays)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.event, size: 18, color: DaysoffColors.brandTeal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.source == 'news'
                              ? '${h.name} · temporary (news-detected)'
                              : h.name),
                          if (h.nameLocal != null && h.nameLocal != h.name)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(h.nameLocal!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: DaysoffColors.neutral500)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (savedBreak != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.bookmark, size: 18, color: DaysoffColors.sage),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Saved: ${savedBreak.label}')),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
