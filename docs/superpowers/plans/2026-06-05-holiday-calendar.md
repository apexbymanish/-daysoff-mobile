# Holiday Calendar View Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a month-grid calendar to the Holidays tab (toggleable with the list) that marks public holidays, news/temp holidays, weekend days, and saved-break ranges, with a tap-for-detail sheet.

**Architecture:** A `holidaysViewProvider` (StateProvider, default `list`) drives a toggle in the Holidays `SliverAppBar`. A `HolidayCalendarView` (ConsumerStatefulWidget) wraps `table_calendar`'s `TableCalendar<Holiday>`, styling cells/markers from `holidaysProvider`, `savedBreaksProvider`, and `weekendProvider`. Tapping a day opens `showDayDetailSheet`.

**Tech Stack:** Flutter, flutter_riverpod, **table_calendar** (new dep), intl.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile` (package `daysoff_mobile`), branch **`feat/holiday-calendar`** (commit there, never switch). Baseline green: full app on main, 55 tests, analyzer clean. Spec: `docs/superpowers/specs/2026-06-05-holiday-calendar-design.md`. Default view stays `list` so existing Home tests are unaffected. `Holiday{date:DateTime, name:String, source:String}` (source `'library'`|`'news'`). `SavedBreak{id,label,start:DateTime,end:DateTime,ptoCost,kind}`. `holidaysProvider(HolidaysQuery(country,year))`. `savedBreaksProvider`→`List<SavedBreak>`. `weekendProvider`→`List<String>` (e.g. `['sat','sun']`). Colors: `DaysoffColors` (brandTeal, sage, sand, neutral500, neutral700, cream...).

## Out of scope
Device-calendar writes, reminders, editing holidays, week/2-week formats, persisting the toggle.

---

## File Structure
```
pubspec.yaml                                          MODIFY: + table_calendar
lib/providers/holidays_view_provider.dart             NEW: HolidaysView enum + provider
lib/screens/home/widgets/day_detail_sheet.dart        NEW: showDayDetailSheet
lib/screens/home/widgets/holiday_calendar_view.dart   NEW: TableCalendar<Holiday>
lib/screens/home/home_screen.dart                     MODIFY: toggle + conditional body slivers
test/providers/holidays_view_provider_test.dart       NEW
test/screens/home/day_detail_sheet_test.dart          NEW
test/screens/home/holiday_calendar_view_test.dart     NEW
test/screens/home/home_toggle_test.dart               NEW
```

---

## Task 1: Add table_calendar + the view provider

**Files:** Modify `pubspec.yaml`; Create `lib/providers/holidays_view_provider.dart`, `test/providers/holidays_view_provider_test.dart`

- [ ] **Step 1: Add the dependency** — run:
```bash
cd /Users/manishadhikari/Documents/Projects/daysoff-mobile && flutter pub add table_calendar
```
Expected: pubspec.yaml gains `table_calendar: ^3.x.x`, `flutter pub get` runs. Then `flutter test` once to confirm the baseline (55) still passes with the dep added.

- [ ] **Step 2: Write the failing test** — `test/providers/holidays_view_provider_test.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/providers/holidays_view_provider.dart';

void main() {
  test('default view is list', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(holidaysViewProvider), HolidaysView.list);
  });
}
```

- [ ] **Step 3: Run → FAIL** — `flutter test test/providers/holidays_view_provider_test.dart`.

- [ ] **Step 4: Implement** — `lib/providers/holidays_view_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which view the Holidays tab shows.
enum HolidaysView { list, calendar }

/// Session-only toggle; defaults to the timeline list.
final holidaysViewProvider =
    StateProvider<HolidaysView>((ref) => HolidaysView.list);
```

- [ ] **Step 5: Run → PASS** — `flutter test test/providers/holidays_view_provider_test.dart`, then `flutter analyze` (clean).

- [ ] **Step 6: Commit**:
```bash
git add pubspec.yaml pubspec.lock lib/providers/holidays_view_provider.dart test/providers/holidays_view_provider_test.dart
git commit -m "feat(calendar): add table_calendar dep + holidaysViewProvider"
```

---

## Task 2: Day detail sheet

**Files:** Create `lib/screens/home/widgets/day_detail_sheet.dart`, `test/screens/home/day_detail_sheet_test.dart`

- [ ] **Step 1: Write the failing test** — `test/screens/home/day_detail_sheet_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/api/models/saved_break.dart';
import 'package:daysoff_mobile/screens/home/widgets/day_detail_sheet.dart';

void main() {
  testWidgets('shows holiday name, news tag, and saved break', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDayDetailSheet(
              context,
              DateTime(2026, 6, 5),
              [
                Holiday(date: DateTime(2026, 6, 5), name: '임시공휴일', source: 'news'),
              ],
              SavedBreak(
                id: 'x', label: 'Summer trip',
                start: DateTime(2026, 6, 4), end: DateTime(2026, 6, 6),
                ptoCost: 1, kind: 'break',
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.textContaining('임시공휴일'), findsOneWidget);
    expect(find.textContaining('news-detected'), findsOneWidget);
    expect(find.textContaining('Summer trip'), findsOneWidget);
  });

  testWidgets('empty day shows nothing-on-this-day', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDayDetailSheet(context, DateTime(2026, 3, 10), const [], null),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing on this day.'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/screens/home/day_detail_sheet_test.dart`.

- [ ] **Step 3: Implement** — `lib/screens/home/widgets/day_detail_sheet.dart`:
```dart
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
                  children: [
                    const Icon(Icons.event, size: 18, color: DaysoffColors.brandTeal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(h.source == 'news'
                          ? '${h.name} · temporary (news-detected)'
                          : h.name),
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
```

- [ ] **Step 4: Run → PASS** — `flutter test test/screens/home/day_detail_sheet_test.dart`, then `flutter analyze`.

- [ ] **Step 5: Commit**:
```bash
git add lib/screens/home/widgets/day_detail_sheet.dart test/screens/home/day_detail_sheet_test.dart
git commit -m "feat(calendar): day detail bottom sheet"
```

---

## Task 3: HolidayCalendarView (TableCalendar)

**Files:** Create `lib/screens/home/widgets/holiday_calendar_view.dart`, `test/screens/home/holiday_calendar_view_test.dart`

- [ ] **Step 1: Write the failing test** — `test/screens/home/holiday_calendar_view_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/screens/home/widgets/holiday_calendar_view.dart';

void main() {
  testWidgets('renders the calendar with a holiday marker for the focused month',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: HolidayCalendarView(
            holidays: [
              Holiday(date: DateTime(2026, 1, 1), name: "New Year's Day", source: 'library'),
            ],
            year: 2026,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('holiday-calendar')), findsOneWidget);
    // January 2026 is focused; Jan 1 has a holiday → a holiday marker renders.
    expect(find.byKey(const Key('holiday-marker')), findsWidgets);
  });
}
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/screens/home/holiday_calendar_view_test.dart`.

- [ ] **Step 3: Implement** — `lib/screens/home/widgets/holiday_calendar_view.dart`:
```dart
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

/// Month-grid calendar for [year]: marks holidays (teal dot), news/temp
/// holidays (sand dot), weekend columns (muted), and saved-break ranges
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
        child: Text('${day.day}',
            style: TextStyle(color: isWeekend ? DaysoffColors.neutral500 : null)),
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
      onPageChanged: (focused) => _focused = focused,
      onDaySelected: (selected, focused) {
        setState(() => _focused = focused);
        showDayDetailSheet(
            context, selected, byDay[_d(selected)] ?? const [], savedFor(selected));
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
                color: hasNews ? DaysoffColors.sand : DaysoffColors.brandTeal,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
```
> Note: `TableCalendar<Holiday>` ties `eventLoader`/`markerBuilder` to `List<Holiday>`, so `e.source` needs no cast. If the analyzer flags `withValues` as undefined (older Flutter), replace `DaysoffColors.sage.withValues(alpha: 0.35)` with `DaysoffColors.sage.withOpacity(0.35)` and add `// ignore: deprecated_member_use` above that line. Check `flutter --version` first; SDK 3.41 supports `withValues`.

- [ ] **Step 4: Run → PASS** — `flutter test test/screens/home/holiday_calendar_view_test.dart`. If the marker isn't found, the focused month may need a `pumpAndSettle()` after build (already present). Then `flutter analyze` (clean).

- [ ] **Step 5: Commit**:
```bash
git add lib/screens/home/widgets/holiday_calendar_view.dart test/screens/home/holiday_calendar_view_test.dart
git commit -m "feat(calendar): HolidayCalendarView with markers + weekend/break styling"
```

---

## Task 4: Holidays tab toggle + conditional body

**Files:** Modify `lib/screens/home/home_screen.dart`; Create `test/screens/home/home_toggle_test.dart`

- [ ] **Step 1: Write the failing test** — `test/screens/home/home_toggle_test.dart`. FIRST read `lib/api/models/holidays_response.dart` to confirm the `HolidaysResponse` constructor field names, and adjust the fake's returned object to match (likely `country`, `year`, `count`, `holidays`).
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/screens/home/home_screen.dart';

class _FakeApiClient extends ApiClient {
  @override
  Future<HolidaysResponse> getHolidays({
    required String country,
    required int year,
    bool fromToday = false,
  }) async =>
      HolidaysResponse(
        country: 'KR',
        year: 2026,
        count: 1,
        holidays: [
          Holiday(date: DateTime(2026, 1, 1), name: "New Year's Day", source: 'library'),
        ],
      );
}

void main() {
  testWidgets('toggle switches between list and calendar', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pumpAndSettle();

    // Default is the list: the holiday card shows the name; no calendar.
    expect(find.text("New Year's Day"), findsOneWidget);
    expect(find.byKey(const Key('holiday-calendar')), findsNothing);

    await tester.tap(find.byKey(const Key('toggle-calendar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('holiday-calendar')), findsOneWidget);

    await tester.tap(find.byKey(const Key('toggle-list')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('holiday-calendar')), findsNothing);
    expect(find.text("New Year's Day"), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/screens/home/home_toggle_test.dart`.

- [ ] **Step 3: Implement** — edit `lib/screens/home/home_screen.dart`:

1. Add imports alongside the existing ones:
```dart
import '../../providers/holidays_view_provider.dart';
import 'widgets/holiday_calendar_view.dart';
```

2. In `_HolidaysList.build` (a `ConsumerWidget`), after the existing `byMonth`/`months` computation, read the view:
```dart
    final view = ref.watch(holidaysViewProvider);
```

3. Add the toggle to the `SliverAppBar` `actions:` — insert these two IconButtons BEFORE the existing bookmark IconButton:
```dart
          actions: [
            IconButton(
              key: const Key('toggle-list'),
              icon: Icon(Icons.view_agenda_outlined,
                  color: view == HolidaysView.list
                      ? DaysoffColors.brandTeal
                      : DaysoffColors.neutral500),
              onPressed: () =>
                  ref.read(holidaysViewProvider.notifier).state = HolidaysView.list,
            ),
            IconButton(
              key: const Key('toggle-calendar'),
              icon: Icon(Icons.calendar_month_outlined,
                  color: view == HolidaysView.calendar
                      ? DaysoffColors.brandTeal
                      : DaysoffColors.neutral500),
              onPressed: () =>
                  ref.read(holidaysViewProvider.notifier).state = HolidaysView.calendar,
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () => context.push(AppRoutes.saved),
            ),
          ],
```

4. Replace the body slivers after the `SliverAppBar` (the `if (upcoming.isNotEmpty) ...` banner and the `for (final month in months) ...` sections) with a conditional on `view`:
```dart
        if (view == HolidaysView.calendar)
          SliverToBoxAdapter(
            child: HolidayCalendarView(holidays: holidays, year: year),
          )
        else ...[
          if (upcoming.isNotEmpty)
            SliverToBoxAdapter(
              child: DaysUntilBanner(next: upcoming.first),
            ),
          for (final month in months) ...[
            SliverToBoxAdapter(child: MonthSection(month: month)),
            SliverList.builder(
              itemCount: byMonth[month]!.length,
              itemBuilder: (context, index) =>
                  HolidayCard(holiday: byMonth[month]![index]),
            ),
          ],
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
```
(Keep the `SliverAppBar` and the trailing 32-height spacer; only the middle body changes.)

- [ ] **Step 4: Run → PASS** — `flutter test test/screens/home/home_toggle_test.dart`.

- [ ] **Step 5: Full gate** — `flutter test` (expect 60 passing: 55 + 5 new across tasks 1–4) and `flutter analyze` (clean). If a pre-existing Home test breaks, investigate — default view is `list`, so the list path is unchanged; report anything you must touch.

- [ ] **Step 6: Commit**:
```bash
git add lib/screens/home/home_screen.dart test/screens/home/home_toggle_test.dart
git commit -m "feat(calendar): list/calendar toggle on Holidays tab"
```

---

## Self-review
- **Spec coverage:** view provider default-list ✓ (T1); table_calendar dep ✓ (T1); day detail sheet (holiday names, news tag, saved break, empty state) ✓ (T2); calendar with holiday/news markers, weekend muting, saved-break fill, tap→sheet ✓ (T3); toggle on Holidays + conditional body, list default ✓ (T4); data from existing providers, no new API ✓.
- **Placeholder scan:** none — full code in every step. The two "read the model first" notes (HolidaysResponse/Holiday constructors) are read-first instructions so the fakes compile, not placeholders.
- **Type consistency:** `HolidaysView{list,calendar}` + `holidaysViewProvider` used in T1/T4; `showDayDetailSheet(BuildContext, DateTime, List<Holiday>, SavedBreak?)` defined T2, called T3; `HolidayCalendarView({holidays, year})` defined T3, used T4; keys `holiday-calendar`/`holiday-marker`/`news-marker`/`toggle-list`/`toggle-calendar` consistent across widget + tests; weekend keys mapped via `_weekdayInts` (sat→6, sun→7) feed `weekendDays`.

## Done when
`flutter test && flutter analyze` clean; the Holidays tab shows a list/calendar toggle, the calendar marks holidays + news/temp + weekends + saved breaks for the selected year, the year stepper changes the calendar's year, and tapping a day opens a detail sheet. Default view is the list (no regression).
