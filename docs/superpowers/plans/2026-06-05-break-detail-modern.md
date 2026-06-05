# Break Detail Modern (6.2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Redesign break detail with a scenery hero, value callout, and a color-coded day-by-day breakdown with native holiday names.

**Architecture:** Rewrite `break_detail_screen.dart` as a `CustomScrollView` (scenery `SliverAppBar` + body). Native holiday names come from `holidaysProvider` (the `name_local` field), looked up by date with graceful degradation. Preserve the existing Save action + the texts/keys the current test relies on.

**Tech Stack:** Flutter, flutter_riverpod, intl. **Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile`, branch **`feat/break-detail-modern`** (commit there, never switch). Baseline: 79 tests, analyzer clean. `PlanTrip{breakStart,breakEnd,breakLength,ptoDates,ptoCost,anchors}`. `Holiday{date,name,nameLocal?,source}`. `classifyBreakDay(day, ptoDates)→BreakDayKind{pto,weekend,holiday}` in `lib/core/break_days.dart`. `holidaysProvider(HolidaysQuery(country,year))` in `lib/providers/holidays_provider.dart`. `selectedCountryProvider`/`selectedYearProvider` in `lib/providers/selection_provider.dart`. `sceneryForDate(DateTime)` in `lib/screens/home/widgets/scenery.dart`. `savedBreaksProvider` + `SavedBreak` (saved-breaks). Colors `DaysoffColors` (brandTeal, sage, peach, neutral100, neutral300, neutral500, neutral700, neutral900). `apiClientProvider` in `lib/providers/api_provider.dart`; `HolidaysResponse{country,year,count,holidays}`.

## Out of scope
Backend native anchor names; share button; bottom-nav restyle.

---

## Task 1: Rewrite break detail (hero + callout + day-by-day + native names)

**Files:** Rewrite `lib/screens/plan/break_detail_screen.dart`; Modify `test/screens/plan/break_detail_test.dart`

- [ ] **Step 1: Add new test cases** to `test/screens/plan/break_detail_test.dart` — KEEP the two existing tests verbatim, and add these (plus the imports they need at the top: `api_client.dart`, `api/models/holiday.dart`, `api/models/holidays_response.dart`, `providers/api_provider.dart`):
```dart
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
          // 2026-09-24 is a Thursday inside the break, not a PTO day → holiday kind.
          Holiday(
            date: DateTime(2026, 9, 24),
            name: 'Chuseok',
            nameLocal: '추석',
            source: 'library',
          ),
        ],
      );
}
```
and these test bodies (inside `main()`):
```dart
  testWidgets('holiday day shows the native name + type tags + scenery hero',
      (tester) async {
    final trip = PlanTrip(
      breakStart: DateTime(2026, 9, 23),
      breakEnd: DateTime(2026, 9, 27),
      breakLength: 5,
      ptoDates: [DateTime(2026, 9, 23)],
      ptoCost: 1,
      anchors: const ['Chuseok'],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: MaterialApp(home: BreakDetailScreen(trip: trip)),
    ));
    await tester.pump(); // resolve holidaysProvider
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SliverAppBar), findsOneWidget);
    expect(find.text('추석'), findsOneWidget);
    expect(find.text('PTO'), findsWidgets);      // the Sep 23 PTO day
    expect(find.text('Weekend'), findsWidgets);  // Sat/Sun in the break
  });
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/screens/plan/break_detail_test.dart` (no SliverAppBar / 추석 yet; the old screen is a plain AppBar list).

- [ ] **Step 3: Rewrite `lib/screens/plan/break_detail_screen.dart`**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../api/models/holiday.dart';
import '../../api/models/plan_trip.dart';
import '../../api/models/saved_break.dart';
import '../../core/break_days.dart';
import '../../providers/holidays_provider.dart';
import '../../providers/saved_breaks_provider.dart';
import '../../providers/selection_provider.dart';
import '../../theme/colors.dart';
import '../home/widgets/scenery.dart';

class BreakDetailScreen extends ConsumerWidget {
  const BreakDetailScreen({super.key, required this.trip});
  final PlanTrip trip;

  DateTime _d0(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(selectedCountryProvider);
    final year = ref.watch(selectedYearProvider);
    final holidaysAsync =
        ref.watch(holidaysProvider(HolidaysQuery(country: country, year: year)));

    final byDay = <DateTime, Holiday>{};
    holidaysAsync.maybeWhen(
      data: (resp) {
        for (final h in resp.holidays) {
          byDay[_d0(h.date)] = h;
        }
      },
      orElse: () {},
    );

    final days = <DateTime>[];
    for (var d = trip.breakStart;
        !d.isAfter(trip.breakEnd);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    final rangeFmt = DateFormat('MMM d');
    final dayFmt = DateFormat('EEE MMM d');
    final anchor = trip.anchors.isNotEmpty ? trip.anchors.first : '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            foregroundColor: Colors.white,
            backgroundColor: DaysoffColors.brandTeal,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Break Details'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    sceneryForDate(trip.breakStart),
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, s) =>
                        const ColoredBox(color: DaysoffColors.brandTeal),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${trip.breakLength}-day break',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      '${rangeFmt.format(trip.breakStart)} – ${rangeFmt.format(trip.breakEnd)}'
                      '${anchor.isEmpty ? '' : '  ·  anchored on $anchor'}',
                      style: const TextStyle(color: DaysoffColors.neutral700),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: DaysoffColors.sage.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 18, color: DaysoffColors.brandTeal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${trip.ptoCost} PTO day${trip.ptoCost == 1 ? '' : 's'} → '
                              '${trip.breakLength} days off',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('DAY-BY-DAY',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: DaysoffColors.neutral500)),
                    const SizedBox(height: 4),
                    for (final d in days)
                      _DayRow(
                        day: d,
                        fmt: dayFmt,
                        kind: classifyBreakDay(d, trip.ptoDates),
                        holiday: byDay[_d0(d)],
                      ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: DaysoffColors.sage),
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text('Save this break'),
                      onPressed: () {
                        ref.read(savedBreaksProvider.notifier).add(SavedBreak(
                              id: 'break-${trip.breakStart.toIso8601String()}',
                              label: '${trip.breakLength}-day break',
                              start: trip.breakStart,
                              end: trip.breakEnd,
                              ptoCost: trip.ptoCost,
                              kind: 'break',
                            ));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saved')));
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.fmt,
    required this.kind,
    this.holiday,
  });

  final DateTime day;
  final DateFormat fmt;
  final BreakDayKind kind;
  final Holiday? holiday;

  @override
  Widget build(BuildContext context) {
    final (String label, Color color) = switch (kind) {
      BreakDayKind.pto => ('PTO', DaysoffColors.sage),
      BreakDayKind.weekend => ('Weekend', DaysoffColors.neutral300),
      BreakDayKind.holiday => (holiday?.name ?? 'Holiday', DaysoffColors.peach),
    };
    final native = kind == BreakDayKind.holiday &&
            holiday?.nameLocal != null &&
            holiday!.nameLocal != holiday.name
        ? holiday.nameLocal
        : null;

    return Container(
      key: const ValueKey('break-day-row'),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DaysoffColors.neutral100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fmt.format(day)),
                if (native != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(native,
                        style: const TextStyle(
                            fontSize: 12, color: DaysoffColors.neutral500)),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DaysoffColors.neutral900)),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run → PASS + full gate** — `flutter test test/screens/plan/break_detail_test.dart` (4 tests: 2 existing + new), then `flutter test` (full, expect ~80) and `flutter analyze` (clean). Note: the two existing tests don't override `holidaysProvider`, so `byDay` is empty there → holiday rows show "Holiday"/the anchor; the assertions they check (`'5-day break'`, `textContaining('1 PTO')`, 5 `break-day-row`s, Save) are preserved.

- [ ] **Step 5: Commit**:
```bash
git add lib/screens/plan/break_detail_screen.dart test/screens/plan/break_detail_test.dart
git commit -m "feat(plan): modern break detail — scenery hero, day-by-day tags, native names"
```

---

## Self-review
- **Coverage:** scenery hero ✓; value callout ✓; day-by-day with color tags ✓; native holiday names via holidaysProvider ✓; Save preserved ✓.
- **Placeholders:** none — full code.
- **Types:** `BreakDetailScreen(trip:)` unchanged (route passes `state.extra as PlanTrip`); `classifyBreakDay`/`Holiday.nameLocal`/`sceneryForDate` reused; day rows keyed `break-day-row`; texts `'5-day break'` + `'… PTO …'` preserved for the existing tests.

## Done when
`flutter test && flutter analyze` clean; break detail shows a scenery hero, a value callout, and a day-by-day list with PTO/Weekend/Holiday tags and native holiday names (when available); Save still works.
