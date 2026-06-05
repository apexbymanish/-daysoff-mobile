# Home 6.1 Redesign Implementation Plan (Sub-project B)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scenery next-break hero + native-language holiday names + weekend-aware FREE/ABSORBED chips on the Holidays list view.

**Architecture:** `Holiday` gains `nameLocal` (from API field `name_local`). A `NextBreakHero` (with a rotating bundled scenery photo) replaces `DaysUntilBanner` in the list view. `HolidayCard` becomes a `ConsumerWidget` showing the native name and a status badge driven by `weekendProvider` via a shared `isAbsorbed` helper.

**Tech Stack:** Flutter, flutter_riverpod, freezed/json_serializable (build_runner), intl.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile`, branch **`feat/home-redesign`** (commit there, never switch). Baseline green: 63 tests, analyzer clean. The 4 optimized scenery JPGs already exist (untracked) at `assets/scenery/{kyoto,alps,cinque_terre,marrakech}.jpg`. The backend (sub-project A, on its main) serves `name_local`. `weekendProvider` (`List<String>`, default `['sat','sun']`) is in `lib/providers/preferences_provider.dart`. `showDayDetailSheet(BuildContext, DateTime, List<Holiday>, SavedBreak?)` is in `lib/screens/home/widgets/day_detail_sheet.dart`. Codegen: `dart run build_runner build --delete-conflicting-outputs`.

## Out of scope
Device-calendar/reminders, the 6.x modern/destination screens, per-country hero mapping, hero animation.

---

## File Structure
```
pubspec.yaml                                       MODIFY: register assets/scenery/
assets/scenery/*.jpg                               (already present; committed in Task 3)
lib/api/models/holiday.dart (+ generated)          MODIFY: nameLocal
lib/core/holiday_status.dart                       NEW: kWeekdayInts + isAbsorbed
lib/screens/home/widgets/scenery.dart              NEW: kScenery + sceneryForDate
lib/screens/home/widgets/next_break_hero.dart      NEW
lib/screens/home/widgets/holiday_card.dart         MODIFY: ConsumerWidget, native name, weekend status
lib/screens/home/widgets/days_until_banner.dart    DELETE
lib/screens/home/widgets/day_detail_sheet.dart     MODIFY: native name line
lib/screens/home/home_screen.dart                  MODIFY: NextBreakHero in list view
test/api/holiday_test.dart                         NEW
test/core/holiday_status_test.dart                 NEW
test/screens/home/holiday_card_test.dart           NEW
test/screens/home/next_break_hero_test.dart        NEW
```

---

## Task 1: Holiday.nameLocal

**Files:** Modify `lib/api/models/holiday.dart` (+ regenerate); Create `test/api/holiday_test.dart`

- [ ] **Step 1: Write the failing test** — `test/api/holiday_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';

void main() {
  test('parses name_local into nameLocal; absent → null', () {
    final h = Holiday.fromJson({
      'date': '2026-02-17', 'name': 'Korean New Year',
      'name_local': '설날', 'source': 'library',
    });
    expect(h.nameLocal, '설날');

    final h2 = Holiday.fromJson({
      'date': '2026-01-01', 'name': 'New Year', 'source': 'library',
    });
    expect(h2.nameLocal, isNull);
  });
}
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/api/holiday_test.dart` (no `nameLocal`).

- [ ] **Step 3: Edit `lib/api/models/holiday.dart`** — add the field:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'holiday.freezed.dart';
part 'holiday.g.dart';

/// One holiday record as returned by GET /v1/holidays.
@freezed
class Holiday with _$Holiday {
  const factory Holiday({
    required DateTime date,
    required String name,
    @JsonKey(name: 'name_local') String? nameLocal,
    required String source,
  }) = _Holiday;

  factory Holiday.fromJson(Map<String, dynamic> json) =>
      _$HolidayFromJson(json);
}
```

- [ ] **Step 4: Regenerate** — `dart run build_runner build --delete-conflicting-outputs` (updates `holiday.freezed.dart` + `holiday.g.dart`).

- [ ] **Step 5: Run → PASS** — `flutter test test/api/holiday_test.dart`, then `flutter test` (full — confirm no regression; existing `Holiday(...)` fakes still compile since `nameLocal` is optional).

- [ ] **Step 6: Commit**:
```bash
git add lib/api/models/holiday.dart lib/api/models/holiday.freezed.dart lib/api/models/holiday.g.dart test/api/holiday_test.dart
git commit -m "feat(home): Holiday.nameLocal (name_local) field"
```

---

## Task 2: holiday_status helper + HolidayCard native name & weekend-aware status

**Files:** Create `lib/core/holiday_status.dart`, `test/core/holiday_status_test.dart`; Modify `lib/screens/home/widgets/holiday_card.dart`; Create `test/screens/home/holiday_card_test.dart`

- [ ] **Step 1: Write the failing helper test** — `test/core/holiday_status_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/core/holiday_status.dart';

void main() {
  test('absorbed when the holiday lands on a weekend day', () {
    // 2026-01-02 is a Friday; 2026-01-03 is a Saturday.
    expect(isAbsorbed(DateTime(2026, 1, 3), const ['sat', 'sun']), true);
    expect(isAbsorbed(DateTime(2026, 1, 2), const ['sat', 'sun']), false);
    expect(isAbsorbed(DateTime(2026, 1, 2), const ['fri']), true);
  });
}
```

- [ ] **Step 2: Run → FAIL.**

- [ ] **Step 3: Create `lib/core/holiday_status.dart`**:
```dart
/// Maps weekday tokens (matching the API workweek tokens) to DateTime weekday ints.
const kWeekdayInts = {
  'mon': DateTime.monday,
  'tue': DateTime.tuesday,
  'wed': DateTime.wednesday,
  'thu': DateTime.thursday,
  'fri': DateTime.friday,
  'sat': DateTime.saturday,
  'sun': DateTime.sunday,
};

/// A holiday is "absorbed" when it falls on one of the user's weekly days off
/// (already a non-working day); otherwise it's a "free" extra day off.
bool isAbsorbed(DateTime date, List<String> weekend) {
  for (final key in weekend) {
    if (kWeekdayInts[key] == date.weekday) return true;
  }
  return false;
}
```

- [ ] **Step 4: Run → PASS** — `flutter test test/core/holiday_status_test.dart`.

- [ ] **Step 5: Write the failing HolidayCard test** — `test/screens/home/holiday_card_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/providers/preferences_provider.dart';
import 'package:daysoff_mobile/screens/home/widgets/holiday_card.dart';

Holiday _h() => Holiday(
      date: DateTime(2026, 1, 2), // Friday
      name: 'Some Holiday',
      nameLocal: '설날',
      source: 'library',
    );

Future<void> _pump(WidgetTester tester, {List<String>? weekend}) {
  return tester.pumpWidget(ProviderScope(
    overrides: [
      if (weekend != null)
        weekendProvider.overrideWith((ref) => weekend),
    ],
    child: MaterialApp(home: Scaffold(body: HolidayCard(holiday: _h()))),
  ));
}

void main() {
  testWidgets('shows the native name', (tester) async {
    await _pump(tester);
    expect(find.text('설날'), findsOneWidget);
  });

  testWidgets('Friday holiday is free by default, absorbed when Fri is a day off',
      (tester) async {
    await _pump(tester);
    expect(find.text('free'), findsOneWidget);

    await _pump(tester, weekend: const ['fri']);
    expect(find.text('absorbed'), findsOneWidget);
  });
}
```

- [ ] **Step 6: Run → FAIL** (HolidayCard isn't a ConsumerWidget / shows no native name).

- [ ] **Step 7: Replace `lib/screens/home/widgets/holiday_card.dart`**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/models/holiday.dart';
import '../../../core/holiday_status.dart';
import '../../../providers/preferences_provider.dart';
import '../../../theme/colors.dart';

/// A single holiday row in the home timeline: date stack, the holiday name
/// (with its native-language name beneath when available), and a free/absorbed
/// badge based on the user's weekend.
class HolidayCard extends ConsumerWidget {
  const HolidayCard({super.key, required this.holiday});

  final Holiday holiday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekend = ref.watch(weekendProvider);
    final absorbed = isAbsorbed(holiday.date, weekend);
    final dayFmt = DateFormat('d');
    final dowFmt = DateFormat('EEE');
    final hasLocal =
        holiday.nameLocal != null && holiday.nameLocal != holiday.name;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DaysoffColors.neutral100, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayFmt.format(holiday.date),
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w600, height: 1.0),
                ),
                const SizedBox(height: 2),
                Text(
                  dowFmt.format(holiday.date).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11,
                      color: DaysoffColors.neutral500,
                      letterSpacing: 0.8),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
                if (hasLocal) ...[
                  const SizedBox(height: 2),
                  Text(
                    holiday.nameLocal!,
                    style: const TextStyle(
                        fontSize: 12, color: DaysoffColors.neutral500),
                  ),
                ],
              ],
            ),
          ),
          _StatusBadge(absorbed: absorbed),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.absorbed});
  final bool absorbed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          absorbed ? Icons.nightlight_round : Icons.wb_sunny_outlined,
          size: 14,
          color: absorbed ? DaysoffColors.neutral500 : DaysoffColors.peachDark,
        ),
        const SizedBox(width: 4),
        Text(
          absorbed ? 'absorbed' : 'free',
          style: TextStyle(
            fontSize: 11,
            color: absorbed ? DaysoffColors.neutral500 : DaysoffColors.peachDark,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 8: Run → PASS** — `flutter test test/core/holiday_status_test.dart test/screens/home/holiday_card_test.dart`, then `flutter test` (full).

- [ ] **Step 9: Commit**:
```bash
git add lib/core/holiday_status.dart lib/screens/home/widgets/holiday_card.dart test/core/holiday_status_test.dart test/screens/home/holiday_card_test.dart
git commit -m "feat(home): native name + weekend-aware free/absorbed on HolidayCard"
```

---

## Task 3: Scenery assets + picker + NextBreakHero

**Files:** Modify `pubspec.yaml`; Create `lib/screens/home/widgets/scenery.dart`, `lib/screens/home/widgets/next_break_hero.dart`, `test/screens/home/next_break_hero_test.dart`

- [ ] **Step 1: Register assets** — in `pubspec.yaml`, under the existing `flutter:` section (which has `uses-material-design: true`), add an `assets:` entry (READ the file first; insert with correct 2-space indentation under `flutter:`):
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/scenery/
```
Run `flutter pub get`.

- [ ] **Step 2: Create `lib/screens/home/widgets/scenery.dart`**:
```dart
/// Bundled aspirational destination photos for the next-break hero.
const kScenery = [
  'assets/scenery/kyoto.jpg',
  'assets/scenery/alps.jpg',
  'assets/scenery/cinque_terre.jpg',
  'assets/scenery/marrakech.jpg',
];

/// Deterministic per-date pick so a given break always shows the same photo
/// but different breaks vary.
String sceneryForDate(DateTime d) =>
    kScenery[(d.month * 31 + d.day) % kScenery.length];
```

- [ ] **Step 3: Write the failing hero test** — `test/screens/home/next_break_hero_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/screens/home/widgets/next_break_hero.dart';

void main() {
  testWidgets('renders the label + holiday name and fires See details',
      (tester) async {
    var tapped = false;
    final next = Holiday(
      date: DateTime.now().add(const Duration(days: 12)),
      name: 'Children\'s Day',
      source: 'library',
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NextBreakHero(next: next, onSeeDetails: () => tapped = true),
      ),
    ));
    await tester.pump();

    expect(find.text('NEXT BREAK IN'), findsOneWidget);
    expect(find.text("Children's Day"), findsOneWidget);

    await tester.tap(find.text('See details'));
    await tester.pump();
    expect(tapped, true);
  });
}
```

- [ ] **Step 4: Run → FAIL.**

- [ ] **Step 5: Create `lib/screens/home/widgets/next_break_hero.dart`**:
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../api/models/holiday.dart';
import '../../../theme/colors.dart';
import 'scenery.dart';

/// Scenery "next break" hero card for the top of the Holidays list.
class NextBreakHero extends StatelessWidget {
  const NextBreakHero({super.key, required this.next, this.onSeeDetails});

  final Holiday next;
  final VoidCallback? onSeeDetails;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = next.date.difference(today).inDays;
    final dateFmt = DateFormat('EEE, MMM d');
    final hasLocal = next.nameLocal != null && next.nameLocal != next.name;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      height: 188,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DaysoffColors.brandTeal, DaysoffColors.sage],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            sceneryForDate(next.date),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEXT BREAK IN',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$days',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('days',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hasLocal ? '${next.name}  ·  ${next.nameLocal}' : next.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  dateFmt.format(next.date),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (onSeeDetails != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: TextButton(
                onPressed: onSeeDetails,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('See details'),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Run → PASS** — `flutter test test/screens/home/next_break_hero_test.dart`.

- [ ] **Step 7: Commit** (includes the asset binaries):
```bash
git add pubspec.yaml assets/scenery/ lib/screens/home/widgets/scenery.dart lib/screens/home/widgets/next_break_hero.dart test/screens/home/next_break_hero_test.dart
git commit -m "feat(home): scenery NextBreakHero + bundled destination assets"
```

---

## Task 4: Wire the hero into Home; native name in the day sheet; delete the banner

**Files:** Modify `lib/screens/home/home_screen.dart`, `lib/screens/home/widgets/day_detail_sheet.dart`; Delete `lib/screens/home/widgets/days_until_banner.dart`; Create `test/screens/home/home_hero_test.dart`

- [ ] **Step 1: Write the failing test** — `test/screens/home/home_hero_test.dart` (uses a FUTURE-dated holiday so the hero shows; READ `lib/api/models/holidays_response.dart` to match the constructor):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/screens/home/home_screen.dart';
import 'package:daysoff_mobile/screens/home/widgets/next_break_hero.dart';

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
          Holiday(
            date: DateTime.now().add(const Duration(days: 20)),
            name: 'Future Holiday',
            source: 'library',
          ),
        ],
      );
}

void main() {
  testWidgets('list view shows the NextBreakHero for an upcoming holiday',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump(); // let the future provider resolve
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(NextBreakHero), findsOneWidget);
    expect(find.text('NEXT BREAK IN'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run → FAIL** (home still uses DaysUntilBanner).

- [ ] **Step 3a: Edit `lib/screens/home/home_screen.dart`**:
  - Remove the import of `widgets/days_until_banner.dart`; add imports:
    ```dart
    import 'widgets/next_break_hero.dart';
    import 'widgets/day_detail_sheet.dart';
    ```
  - In the **list** branch (the `else ...[` block from the calendar task), replace the banner sliver:
    ```dart
          if (upcoming.isNotEmpty)
            SliverToBoxAdapter(
              child: NextBreakHero(
                next: upcoming.first,
                onSeeDetails: () => showDayDetailSheet(
                  context, upcoming.first.date, [upcoming.first], null),
              ),
            ),
    ```
    (Leave the `for (final month in months) ...` sections and everything else unchanged.)

- [ ] **Step 3b: Edit `lib/screens/home/widgets/day_detail_sheet.dart`** — show the native name under each holiday's name. Replace the holiday `for (final h in holidays) ...` row's `Expanded(child: Text(...))` with a Column:
```dart
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
```

- [ ] **Step 3c: Delete the banner** — `git rm lib/screens/home/widgets/days_until_banner.dart` (confirmed no remaining references after Step 3a; the calendar task and tests don't use it).

- [ ] **Step 4: Run → PASS + full gate** — `flutter test test/screens/home/home_hero_test.dart`, then `flutter test` (expect ~70: 63 + 7 new across tasks) and `flutter analyze` (clean). If a pre-existing test referenced `DaysUntilBanner`, update it (none do as of baseline). The existing `home_toggle_test` uses a past-dated holiday (Jan 1) so no hero shows there — it should still pass unchanged.

- [ ] **Step 5: Commit**:
```bash
git add lib/screens/home/home_screen.dart lib/screens/home/widgets/day_detail_sheet.dart test/screens/home/home_hero_test.dart
git rm lib/screens/home/widgets/days_until_banner.dart
git commit -m "feat(home): use NextBreakHero in list view; native name in day sheet"
```

---

## Self-review
- **Spec coverage:** nameLocal ✓ (T1); native name in rows + weekend-aware status via shared helper ✓ (T2); scenery assets + rotating picker + hero ✓ (T3); hero wired into list view + native name in day sheet + banner removed ✓ (T4).
- **Placeholder scan:** none — full code. The "read holidays_response.dart / pubspec first" notes are read-first instructions, not placeholders.
- **Type consistency:** `Holiday.nameLocal` (String?) used in HolidayCard, NextBreakHero, day sheet; `isAbsorbed(DateTime, List<String>)` from `holiday_status.dart` used in HolidayCard; `kScenery`/`sceneryForDate(DateTime)` used by the hero; `NextBreakHero({next, onSeeDetails})` used by home_screen; `showDayDetailSheet(...)` reused for "See details".

## Done when
`flutter test && flutter analyze` clean; the Holidays list view shows a scenery hero with the next-break countdown, holiday rows show native names + free/absorbed (respecting the weekend pref), the day sheet shows native names, and the calendar view still works.
