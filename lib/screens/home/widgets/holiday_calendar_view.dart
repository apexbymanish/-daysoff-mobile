import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../api/models/holiday.dart';
import '../../../api/models/saved_break.dart';
import '../../../providers/preferences_provider.dart';
import '../../../providers/saved_breaks_provider.dart';
import '../../../theme/colors.dart';
import 'day_detail_sheet.dart';

const _weekdayInts = {
  'mon': DateTime.monday,
  'tue': DateTime.tuesday,
  'wed': DateTime.wednesday,
  'thu': DateTime.thursday,
  'fri': DateTime.friday,
  'sat': DateTime.saturday,
  'sun': DateTime.sunday,
};

// DaysoffColors has no `sand` token; using `peach` (warm accent, "free days")
// as the closest substitute for news/temp holiday markers.
const _sandSubstitute = DaysoffColors.peach;

/// Month-grid calendar for [year]: marks holidays (teal dot), news/temp
/// holidays (peach/sand dot), weekend columns (muted), and saved-break ranges
/// (sage fill). Tapping a day opens [showDayDetailSheet].
class HolidayCalendarView extends ConsumerStatefulWidget {
  const HolidayCalendarView({super.key, required this.holidays, required this.year});

  final List<Holiday> holidays;
  final int year;

  @override
  ConsumerState<HolidayCalendarView> createState() => _HolidayCalendarViewState();
}

class _HolidayCalendarViewState extends ConsumerState<HolidayCalendarView> {
  late DateTime _focused;

  @override
  void initState() {
    super.initState();
    _focused = DateTime(widget.year, 1, 1);
  }

  @override
  void didUpdateWidget(HolidayCalendarView old) {
    super.didUpdateWidget(old);
    if (old.year != widget.year) _focused = DateTime(widget.year, 1, 1);
  }

  DateTime _d(DateTime x) => DateTime(x.year, x.month, x.day);

  @override
  Widget build(BuildContext context) {
    final weekend = ref.watch(weekendProvider);
    final saved = ref.watch(savedBreaksProvider);
    final weekendInts = weekend.map((k) => _weekdayInts[k]!).toList();

    final byDay = <DateTime, List<Holiday>>{};
    for (final h in widget.holidays) {
      byDay.putIfAbsent(_d(h.date), () => []).add(h);
    }

    SavedBreak? savedFor(DateTime day) {
      final d = _d(day);
      for (final b in saved) {
        if (!d.isBefore(_d(b.start)) && !d.isAfter(_d(b.end))) return b;
      }
      return null;
    }

    Widget cell(DateTime day, {bool today = false}) {
      final inBreak = savedFor(day) != null;
      final isWeekend = weekendInts.contains(day.weekday);
      return Container(
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: inBreak ? DaysoffColors.sage.withValues(alpha: 0.35) : null,
          borderRadius: BorderRadius.circular(8),
          border: today
              ? Border.all(color: DaysoffColors.brandTeal, width: 1.5)
              : null,
        ),
        child: Text(
          '${day.day}',
          style: TextStyle(color: isWeekend ? DaysoffColors.neutral500 : null),
        ),
      );
    }

    return TableCalendar<Holiday>(
      key: const Key('holiday-calendar'),
      firstDay: DateTime(widget.year, 1, 1),
      lastDay: DateTime(widget.year, 12, 31),
      focusedDay: _focused,
      calendarFormat: CalendarFormat.month,
      availableGestures: AvailableGestures.horizontalSwipe,
      weekendDays: weekendInts,
      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
      eventLoader: (day) => byDay[_d(day)] ?? const [],
      onPageChanged: (focused) => setState(() => _focused = focused),
      onDaySelected: (selected, focused) {
        setState(() => _focused = focused);
        showDayDetailSheet(
          context,
          selected,
          byDay[_d(selected)] ?? const [],
          savedFor(selected),
        );
      },
      calendarBuilders: CalendarBuilders<Holiday>(
        defaultBuilder: (context, day, focusedDay) => cell(day),
        todayBuilder: (context, day, focusedDay) => cell(day, today: true),
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return const SizedBox.shrink();
          final hasNews = events.any((e) => e.source == 'news');
          return Positioned(
            bottom: 6,
            child: Container(
              key: Key(hasNews ? 'news-marker' : 'holiday-marker'),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: hasNews ? _sandSubstitute : DaysoffColors.brandTeal,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
