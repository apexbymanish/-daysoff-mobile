import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../api/models/holiday.dart';
import '../../../providers/holidays_view_provider.dart';
import '../../../providers/preferences_provider.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import 'day_summary_card.dart';

const _weekdayInts = {
  'mon': DateTime.monday,
  'tue': DateTime.tuesday,
  'wed': DateTime.wednesday,
  'thu': DateTime.thursday,
  'fri': DateTime.friday,
  'sat': DateTime.saturday,
  'sun': DateTime.sunday,
};

/// Month-grid calendar for [year].
///
/// Marks holiday days with an olive-tinted circular fill and a small sun icon
/// (free days) or a `surfaceVariant` fill (absorbed days). Weekend columns are
/// dimmed. The selected day shows a 2px brandTeal ring.
///
/// Below the calendar a legend row and an inline [DaySummaryCard] are rendered
/// showing the currently selected day — tapping a day updates the inline card
/// instead of opening a bottom sheet.
class HolidayCalendarView extends ConsumerStatefulWidget {
  const HolidayCalendarView({
    super.key,
    required this.holidays,
    required this.year,
  });

  final List<Holiday> holidays;
  final int year;

  @override
  ConsumerState<HolidayCalendarView> createState() =>
      _HolidayCalendarViewState();
}

class _HolidayCalendarViewState extends ConsumerState<HolidayCalendarView> {
  late DateTime _focused;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _focused = DateTime(widget.year, 1, 1);
    _selected = _defaultSelected();

    // If calendarFocusProvider is set to an in-year date, seed focus/selection.
    final focus = ref.read(calendarFocusProvider);
    if (focus != null &&
        !focus.isBefore(DateTime(widget.year, 1, 1)) &&
        !focus.isAfter(DateTime(widget.year, 12, 31))) {
      _focused = focus;
      _selected = focus;
      // Clear after the current frame so later manual opens use the default.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(calendarFocusProvider.notifier).state = null;
      });
    }
  }

  @override
  void didUpdateWidget(HolidayCalendarView old) {
    super.didUpdateWidget(old);
    if (old.year != widget.year) {
      _focused = DateTime(widget.year, 1, 1);
      _selected = _defaultSelected();
    }
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  DateTime _norm(DateTime x) => DateTime(x.year, x.month, x.day);

  /// First holiday in this year, falling back to today-if-in-year or Jan 1.
  DateTime _defaultSelected() {
    final sorted = widget.holidays
        .where((h) => h.date.year == widget.year)
        .map((h) => _norm(h.date))
        .toList()
      ..sort();
    if (sorted.isNotEmpty) return sorted.first;

    final today = _norm(DateTime.now());
    if (today.year == widget.year) return today;
    return DateTime(widget.year, 1, 1);
  }

  Map<DateTime, Holiday> _buildHolidayMap() {
    final map = <DateTime, Holiday>{};
    for (final h in widget.holidays) {
      map[_norm(h.date)] = h;
    }
    return map;
  }

  // ── day cell builder ───────────────────────────────────────────────────────

  Widget _dayCell(
    DateTime day,
    Map<DateTime, Holiday> byDay,
    List<int> weekendInts, {
    bool outside = false,
  }) {
    final key = _norm(day);
    final isHoliday = byDay.containsKey(key);
    final isWeekend = weekendInts.contains(day.weekday);
    final isSelected = key == _norm(_selected);

    // Text color
    Color textColor;
    if (outside) {
      textColor = DaysoffColors.neutral500.withValues(alpha: 0.4);
    } else if (isWeekend) {
      textColor = DaysoffColors.neutral500;
    } else {
      textColor = DaysoffColors.neutral900;
    }

    return Container(
      margin: const EdgeInsets.all(3),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Holiday circular fill
          if (isHoliday && !outside)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DaysoffColors.oliveFixedDim.withValues(alpha: 0.4),
                ),
              ),
            ),
          // Selected ring (outermost, on top of fill)
          if (isSelected && !outside)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DaysoffColors.brandTeal,
                    width: 2,
                  ),
                ),
              ),
            ),
          // Day number + optional sun icon
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: textColor,
                ),
              ),
              if (isHoliday && !outside)
                Icon(
                  key: const Key('holiday-marker'),
                  Icons.wb_sunny,
                  size: 12,
                  color: DaysoffColors.brandTeal,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final weekend = ref.watch(weekendProvider);
    final weekendInts = weekend.map((k) => _weekdayInts[k]!).toList();
    final byDay = _buildHolidayMap();
    final selectedHoliday = byDay[_norm(_selected)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Calendar ────────────────────────────────────────────────────────
        TableCalendar<Holiday>(
          key: const Key('holiday-calendar'),
          firstDay: DateTime(widget.year, 1, 1),
          lastDay: DateTime(widget.year, 12, 31),
          focusedDay: _focused,
          calendarFormat: CalendarFormat.month,
          availableGestures: AvailableGestures.horizontalSwipe,
          weekendDays: weekendInts,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          selectedDayPredicate: (day) => _norm(day) == _norm(_selected),
          onPageChanged: (focused) => setState(() => _focused = focused),
          onDaySelected: (selected, focused) {
            setState(() {
              _selected = _norm(selected);
              _focused = focused;
            });
          },
          calendarBuilders: CalendarBuilders<Holiday>(
            defaultBuilder: (context, day, focusedDay) =>
                _dayCell(day, byDay, weekendInts),
            todayBuilder: (context, day, focusedDay) =>
                _dayCell(day, byDay, weekendInts),
            selectedBuilder: (context, day, focusedDay) =>
                _dayCell(day, byDay, weekendInts),
            outsideBuilder: (context, day, focusedDay) =>
                _dayCell(day, byDay, weekendInts, outside: true),
            disabledBuilder: (context, day, focusedDay) =>
                _dayCell(day, byDay, weekendInts, outside: true),
          ),
        ),

        const SizedBox(height: 16),

        // ── Legend ──────────────────────────────────────────────────────────
        _CalendarLegend(),

        const SizedBox(height: 16),

        // ── Inline Day Summary Card ──────────────────────────────────────────
        DaySummaryCard(
          day: _selected,
          holiday: selectedHoliday,
          weekend: weekend,
        ),
      ],
    );
  }
}

// ─── Legend row ───────────────────────────────────────────────────────────────

class _CalendarLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          indicator: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DaysoffColors.oliveFixedDim.withValues(alpha: 0.6),
            ),
            child: const Center(
              child: Icon(
                Icons.wb_sunny,
                size: 7,
                color: DaysoffColors.brandTeal,
              ),
            ),
          ),
          label: 'FREE DAY',
        ),
        const SizedBox(width: 20),
        _LegendItem(
          indicator: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DaysoffColors.surfaceVariant,
            ),
            child: Center(
              child: Icon(
                Icons.dark_mode,
                size: 7,
                color: DaysoffColors.neutral500,
              ),
            ),
          ),
          label: 'ABSORBED',
        ),
        const SizedBox(width: 20),
        _LegendItem(
          indicator: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: DaysoffColors.brandTeal,
                width: 1.5,
              ),
            ),
          ),
          label: 'SELECTED',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.indicator, required this.label});

  final Widget indicator;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(width: 4),
        Text(
          label,
          style: labelCaps(
            fontSize: 10,
            color: DaysoffColors.neutral500,
          ),
        ),
      ],
    );
  }
}
