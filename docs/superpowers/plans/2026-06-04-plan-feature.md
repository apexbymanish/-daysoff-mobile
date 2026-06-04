# daysoff-mobile — Plan Feature ("Phase 3") Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Flesh out the `plan_screen` stub into the "length buffet" surface — fetch `/v1/plan` for KR 2026, show the best break of each length (3–10 days) as cards, and drill into a break-detail screen — in the repo's existing Riverpod + go_router + freezed idiom.

**Architecture:** Mirror the Holidays feature exactly. `freezed` models in `lib/api/models/` → `ApiClient.getPlan` (dio) → `planProvider` (`FutureProvider.family`) → `PlanScreen` (`ConsumerWidget` with `.when(loading/error/data)`) + feature widgets under `lib/screens/plan/widgets/`. Break detail is a new go_router route. No new packages; tests use `ProviderScope`/`ProviderContainer` overrides (the repo's established no-mock idiom).

**Tech Stack:** Flutter, flutter_riverpod, go_router, dio, freezed + json_serializable, intl. Build runner for codegen.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile` (package `daysoff_mobile`), branch `main` (in sync with origin). Baseline is green: `flutter pub get`, `flutter analyze` (clean), `flutter test` (1 passing). All commands run from the repo root.

## Verified `/v1/plan` contract (from daysoff-api `api/schemas.py`)

`GET /v1/plan?country=KR&year=2026&budget=15&min_length=3&max_length=10` →
```json
{
  "country": "KR", "year": 2026, "budget": 15,
  "workweek": ["sat","sun"], "workweek_source": "default",
  "results_by_length": {
    "5": [{
      "break_start": "2026-09-23", "break_end": "2026-09-27",
      "break_length": 5, "pto_dates": ["2026-09-23"], "pto_cost": 1,
      "anchors": ["The day preceding Chuseok","Chuseok","The second day of Chuseok"]
    }]
  }
}
```
`results_by_length` is keyed by the break length (string), each value a list of trips ranked best-first. JSON is **snake_case** → map with `@JsonKey(name: ...)`. `break_start`/`break_end` are date strings → `DateTime`; `pto_dates` is `List<DateTime>`.

## Existing patterns to follow (do not deviate)
- Models: `@freezed class X with _$X { const factory X({required ...}) = _X; factory X.fromJson(...) => _$XFromJson(json); }` with `part 'x.freezed.dart'; part 'x.g.dart';`. See `lib/api/models/holiday.dart`.
- ApiClient method: `final res = await _dio.get<Map<String,dynamic>>(Endpoints.plan, queryParameters: {...}); return PlanResponse.fromJson(res.data!);`. See `getHolidays`.
- Provider: a `*Query` value class with `==`/`hashCode` + `FutureProvider.family`. See `lib/providers/holidays_provider.dart`.
- Screen: `ConsumerWidget`, `ref.watch(provider(query)).when(loading/error/data)`, colors from `DaysoffColors`. See `lib/screens/home/home_screen.dart`.
- Tests: override providers in `ProviderScope`/`ProviderContainer` (see `test/widget_test.dart`). No mocktail.

## Out of scope (this phase)
Sandwich screen (separate stub), workweek/budget editing UI (use defaults: budget 15, min 3, max 10), country picker (hardcode KR/2026), calendar/reminders. Anchors render as plain text (no holiday cross-reference).

---

## File Structure (this phase)

```
lib/api/models/plan_trip.dart            (+ .freezed.dart + .g.dart via codegen)
lib/api/models/plan_response.dart        (+ .freezed.dart + .g.dart via codegen)
lib/api/api_client.dart                  MODIFY: add getPlan()
lib/providers/plan_provider.dart         PlanQuery + planProvider
lib/screens/plan/widgets/pto_cost_pill.dart
lib/screens/plan/widgets/day_ribbon.dart
lib/screens/plan/widgets/break_card.dart
lib/screens/plan/plan_screen.dart        REPLACE stub: length buffet + states
lib/screens/plan/break_detail_screen.dart
lib/router/app_router.dart               MODIFY: add break-detail route
test/api/models/plan_models_test.dart
test/providers/plan_provider_test.dart
test/screens/plan/break_card_test.dart
test/screens/plan/plan_screen_test.dart
```

---

## Task 1: Plan freezed models (PlanTrip + PlanResponse)

**Files:**
- Create: `lib/api/models/plan_trip.dart`, `lib/api/models/plan_response.dart`
- Create (codegen): the matching `.freezed.dart` + `.g.dart`
- Test: `test/api/models/plan_models_test.dart`

- [ ] **Step 1: Write the failing test**

`test/api/models/plan_models_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';

void main() {
  const tripJson = {
    'break_start': '2026-09-23',
    'break_end': '2026-09-27',
    'break_length': 5,
    'pto_dates': ['2026-09-23'],
    'pto_cost': 1,
    'anchors': ['Chuseok'],
  };

  test('PlanTrip.fromJson maps snake_case + dates', () {
    final t = PlanTrip.fromJson(tripJson);
    expect(t.breakStart, DateTime(2026, 9, 23));
    expect(t.breakEnd, DateTime(2026, 9, 27));
    expect(t.breakLength, 5);
    expect(t.ptoDates, [DateTime(2026, 9, 23)]);
    expect(t.ptoCost, 1);
    expect(t.anchors, ['Chuseok']);
  });

  test('PlanResponse.fromJson parses results_by_length map', () {
    final r = PlanResponse.fromJson({
      'country': 'KR',
      'year': 2026,
      'budget': 15,
      'workweek': ['sat', 'sun'],
      'workweek_source': 'default',
      'results_by_length': {
        '5': [tripJson],
      },
    });
    expect(r.country, 'KR');
    expect(r.budget, 15);
    expect(r.workweekSource, 'default');
    expect(r.resultsByLength['5']!.single.breakLength, 5);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/api/models/plan_models_test.dart`
Expected: FAIL — `Target of URI doesn't exist` (model files + generated parts missing).

- [ ] **Step 3: Write the model sources**

`lib/api/models/plan_trip.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_trip.freezed.dart';
part 'plan_trip.g.dart';

/// One suggested break from GET /v1/plan (an item of results_by_length).
@freezed
class PlanTrip with _$PlanTrip {
  const factory PlanTrip({
    @JsonKey(name: 'break_start') required DateTime breakStart,
    @JsonKey(name: 'break_end') required DateTime breakEnd,
    @JsonKey(name: 'break_length') required int breakLength,
    @JsonKey(name: 'pto_dates') required List<DateTime> ptoDates,
    @JsonKey(name: 'pto_cost') required int ptoCost,
    required List<String> anchors,
  }) = _PlanTrip;

  factory PlanTrip.fromJson(Map<String, dynamic> json) =>
      _$PlanTripFromJson(json);
}
```

`lib/api/models/plan_response.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'plan_trip.dart';

part 'plan_response.freezed.dart';
part 'plan_response.g.dart';

/// Top-level shape of GET /v1/plan.
@freezed
class PlanResponse with _$PlanResponse {
  const factory PlanResponse({
    required String country,
    required int year,
    required int budget,
    required List<String> workweek,
    @JsonKey(name: 'workweek_source') required String workweekSource,
    @JsonKey(name: 'results_by_length')
    required Map<String, List<PlanTrip>> resultsByLength,
  }) = _PlanResponse;

  factory PlanResponse.fromJson(Map<String, dynamic> json) =>
      _$PlanResponseFromJson(json);
}
```

- [ ] **Step 4: Generate freezed/json code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: builds `plan_trip.freezed.dart`, `plan_trip.g.dart`, `plan_response.freezed.dart`, `plan_response.g.dart` with no errors.

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/api/models/plan_models_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit**
```bash
git add lib/api/models/plan_trip.dart lib/api/models/plan_response.dart lib/api/models/plan_trip.freezed.dart lib/api/models/plan_trip.g.dart lib/api/models/plan_response.freezed.dart lib/api/models/plan_response.g.dart test/api/models/plan_models_test.dart
git commit -m "feat(plan): add PlanTrip + PlanResponse freezed models"
```

---

## Task 2: ApiClient.getPlan + planProvider

**Files:**
- Modify: `lib/api/api_client.dart` (add `getPlan`)
- Create: `lib/providers/plan_provider.dart`
- Test: `test/providers/plan_provider_test.dart`

- [ ] **Step 1: Write the failing test**

`test/providers/plan_provider_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/providers/plan_provider.dart';

class _FakeApiClient extends ApiClient {
  @override
  Future<PlanResponse> getPlan({
    required String country,
    required int year,
    int budget = 15,
    int minLength = 3,
    int maxLength = 10,
  }) async =>
      PlanResponse(
        country: country,
        year: year,
        budget: budget,
        workweek: const ['sat', 'sun'],
        workweekSource: 'default',
        resultsByLength: {
          '5': [
            PlanTrip(
              breakStart: DateTime(2026, 9, 23),
              breakEnd: DateTime(2026, 9, 27),
              breakLength: 5,
              ptoDates: [DateTime(2026, 9, 23)],
              ptoCost: 1,
              anchors: const ['Chuseok'],
            ),
          ],
        },
      );
}

void main() {
  test('planProvider returns the ApiClient result', () async {
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      planProvider(const PlanQuery(country: 'KR', year: 2026, budget: 15)).future,
    );

    expect(result.resultsByLength['5']!.single.ptoCost, 1);
  });

  test('PlanQuery value equality', () {
    expect(
      const PlanQuery(country: 'KR', year: 2026, budget: 15),
      const PlanQuery(country: 'KR', year: 2026, budget: 15),
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/plan_provider_test.dart`
Expected: FAIL — undefined `getPlan`/`planProvider`/`PlanQuery`.

- [ ] **Step 3: Implement getPlan + provider**

Append `getPlan` to the `ApiClient` class in `lib/api/api_client.dart` (after `getHolidays`, before the closing brace). Add the model imports at the top (`import 'models/plan_response.dart';`):
```dart
  Future<PlanResponse> getPlan({
    required String country,
    required int year,
    int budget = 15,
    int minLength = 3,
    int maxLength = 10,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Endpoints.plan,
      queryParameters: {
        'country': country,
        'year': year,
        'budget': budget,
        'min_length': minLength,
        'max_length': maxLength,
      },
    );
    return PlanResponse.fromJson(response.data!);
  }
```

`lib/providers/plan_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models/plan_response.dart';
import 'api_provider.dart';

/// Args for the plan query.
class PlanQuery {
  const PlanQuery({
    required this.country,
    required this.year,
    this.budget = 15,
    this.minLength = 3,
    this.maxLength = 10,
  });

  final String country;
  final int year;
  final int budget;
  final int minLength;
  final int maxLength;

  @override
  bool operator ==(Object other) =>
      other is PlanQuery &&
      other.country == country &&
      other.year == year &&
      other.budget == budget &&
      other.minLength == minLength &&
      other.maxLength == maxLength;

  @override
  int get hashCode => Object.hash(country, year, budget, minLength, maxLength);
}

/// Fetches /v1/plan for the given query.
final planProvider = FutureProvider.family<PlanResponse, PlanQuery>((ref, q) {
  final api = ref.watch(apiClientProvider);
  return api.getPlan(
    country: q.country,
    year: q.year,
    budget: q.budget,
    minLength: q.minLength,
    maxLength: q.maxLength,
  );
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/plan_provider_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**
```bash
git add lib/api/api_client.dart lib/providers/plan_provider.dart test/providers/plan_provider_test.dart
git commit -m "feat(plan): add ApiClient.getPlan + planProvider"
```

---

## Task 3: Plan widgets (PtoCostPill, DayRibbon, BreakCard)

**Files:**
- Create: `lib/screens/plan/widgets/pto_cost_pill.dart`, `lib/screens/plan/widgets/day_ribbon.dart`, `lib/screens/plan/widgets/break_card.dart`
- Test: `test/screens/plan/break_card_test.dart`

- [ ] **Step 1: Write the failing test**

`test/screens/plan/break_card_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/screens/plan/widgets/break_card.dart';
import 'package:daysoff_mobile/screens/plan/widgets/pto_cost_pill.dart';

PlanTrip _trip() => PlanTrip(
      breakStart: DateTime(2026, 9, 23),
      breakEnd: DateTime(2026, 9, 27),
      breakLength: 5,
      ptoDates: [DateTime(2026, 9, 23)],
      ptoCost: 1,
      anchors: const ['Chuseok'],
    );

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('BreakCard shows length, range, PTO pill and anchor', (tester) async {
    await tester.pumpWidget(_host(BreakCard(trip: _trip(), onTap: () {})));
    expect(find.text('5 days'), findsOneWidget);
    expect(find.text('1 PTO'), findsOneWidget);
    expect(find.textContaining('Chuseok'), findsOneWidget);
  });

  testWidgets('tapping the card fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_host(BreakCard(trip: _trip(), onTap: () => tapped = true)));
    await tester.tap(find.byType(BreakCard));
    expect(tapped, isTrue);
  });

  testWidgets('PtoCostPill formats zero as Free', (tester) async {
    await tester.pumpWidget(_host(const PtoCostPill(cost: 0)));
    expect(find.text('Free'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/plan/break_card_test.dart`
Expected: FAIL — undefined `BreakCard`/`PtoCostPill`.

- [ ] **Step 3: Implement the widgets**

`lib/screens/plan/widgets/pto_cost_pill.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

class PtoCostPill extends StatelessWidget {
  const PtoCostPill({super.key, required this.cost});
  final int cost;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    if (cost == 0) {
      bg = DaysoffColors.peach;
    } else if (cost <= 2) {
      bg = DaysoffColors.sage;
    } else {
      bg = DaysoffColors.neutral300;
    }
    final label = cost == 0 ? 'Free' : '$cost PTO';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: DaysoffColors.neutral900)),
    );
  }
}
```

`lib/screens/plan/widgets/day_ribbon.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../api/models/plan_trip.dart';
import '../../../theme/colors.dart';

/// A horizontal strip of colored blocks, one per day of the break.
/// Within a break every day is off — classify as PTO, weekend, or holiday
/// (a day that is neither PTO nor weekend must be the anchoring holiday).
class DayRibbon extends StatelessWidget {
  const DayRibbon({super.key, required this.trip});
  final PlanTrip trip;

  static const _weekend = {DateTime.saturday, DateTime.sunday};

  Color _colorFor(DateTime day) {
    final isPto = trip.ptoDates.any((p) =>
        p.year == day.year && p.month == day.month && p.day == day.day);
    if (isPto) return DaysoffColors.sage; // PTO
    if (_weekend.contains(day.weekday)) return DaysoffColors.brandTeal; // weekend
    return DaysoffColors.peach; // holiday
  }

  @override
  Widget build(BuildContext context) {
    final days = <DateTime>[];
    for (var d = trip.breakStart;
        !d.isAfter(trip.breakEnd);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return SizedBox(
      height: 10,
      child: Row(
        children: [
          for (final d in days)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: _colorFor(d),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

`lib/screens/plan/widgets/break_card.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../api/models/plan_trip.dart';
import '../../../theme/colors.dart';
import 'day_ribbon.dart';
import 'pto_cost_pill.dart';

class BreakCard extends StatelessWidget {
  const BreakCard({super.key, required this.trip, required this.onTap});
  final PlanTrip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d');
    final range = '${fmt.format(trip.breakStart)} – ${fmt.format(trip.breakEnd)}';
    final anchor = trip.anchors.isNotEmpty ? trip.anchors.first : '';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DaysoffColors.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DaysoffColors.neutral300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${trip.breakLength} days',
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(range,
                          style: const TextStyle(
                              fontSize: 13, color: DaysoffColors.neutral700)),
                    ],
                  ),
                ),
                PtoCostPill(cost: trip.ptoCost),
              ],
            ),
            const SizedBox(height: 12),
            DayRibbon(trip: trip),
            const SizedBox(height: 12),
            Text('Anchored on $anchor',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: DaysoffColors.brandTeal)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/screens/plan/break_card_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**
```bash
git add lib/screens/plan/widgets test/screens/plan/break_card_test.dart
git commit -m "feat(plan): add PtoCostPill, DayRibbon, BreakCard widgets"
```

---

## Task 4: PlanScreen (length buffet + states)

**Files:**
- Replace: `lib/screens/plan/plan_screen.dart`
- Test: `test/screens/plan/plan_screen_test.dart`

- [ ] **Step 1: Write the failing test**

`test/screens/plan/plan_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/providers/plan_provider.dart';
import 'package:daysoff_mobile/screens/plan/plan_screen.dart';
import 'package:daysoff_mobile/screens/plan/widgets/break_card.dart';

PlanResponse _resp() => PlanResponse(
      country: 'KR',
      year: 2026,
      budget: 15,
      workweek: const ['sat', 'sun'],
      workweekSource: 'default',
      resultsByLength: {
        '3': [
          PlanTrip(
            breakStart: DateTime(2026, 10, 9),
            breakEnd: DateTime(2026, 10, 11),
            breakLength: 3,
            ptoDates: const [],
            ptoCost: 0,
            anchors: const ['Hangul Day'],
          ),
        ],
        '5': [
          PlanTrip(
            breakStart: DateTime(2026, 9, 23),
            breakEnd: DateTime(2026, 9, 27),
            breakLength: 5,
            ptoDates: [DateTime(2026, 9, 23)],
            ptoCost: 1,
            anchors: const ['Chuseok'],
          ),
        ],
      },
    );

void main() {
  testWidgets('renders one BreakCard per length, ascending', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        planProvider(const PlanQuery(country: 'KR', year: 2026, budget: 15))
            .overrideWith((ref) async => _resp()),
      ],
      child: const MaterialApp(home: PlanScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(BreakCard), findsNWidgets(2));
    expect(find.text('3 days'), findsOneWidget);
    expect(find.text('5 days'), findsOneWidget);
  });

  testWidgets('error state shows Retry', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        planProvider(const PlanQuery(country: 'KR', year: 2026, budget: 15))
            .overrideWith((ref) async => throw Exception('boom')),
      ],
      child: const MaterialApp(home: PlanScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/plan/plan_screen_test.dart`
Expected: FAIL — `PlanScreen` is still the stub (no `BreakCard`).

- [ ] **Step 3: Implement the screen**

Replace `lib/screens/plan/plan_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models/plan_response.dart';
import '../../api/models/plan_trip.dart';
import '../../providers/plan_provider.dart';
import '../../router/app_router.dart';
import '../../theme/colors.dart';
import 'widgets/break_card.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  static const _query = PlanQuery(country: 'KR', year: 2026, budget: 15);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider(_query));
    return Scaffold(
      appBar: AppBar(title: const Text('Plan your year')),
      body: SafeArea(
        child: planAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _PlanError(onRetry: () => ref.invalidate(planProvider(_query))),
          data: (resp) => _Buffet(response: resp),
        ),
      ),
    );
  }
}

class _Buffet extends StatelessWidget {
  const _Buffet({required this.response});
  final PlanResponse response;

  /// Best (first) trip of each length, ordered by ascending length.
  List<PlanTrip> get _bestPerLength {
    final lengths = response.resultsByLength.keys
        .map(int.parse)
        .toList()
      ..sort();
    return [
      for (final len in lengths)
        if (response.resultsByLength['$len']!.isNotEmpty)
          response.resultsByLength['$len']!.first,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final trips = _bestPerLength;
    if (trips.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No breaks fit this budget. Try increasing it.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: DaysoffColors.neutral700)),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '🇰🇷 KR · ${response.year} · budget ${response.budget} days',
            style: const TextStyle(fontSize: 13, color: DaysoffColors.neutral700),
          ),
        ),
        for (final t in trips)
          BreakCard(
            trip: t,
            onTap: () => context.push(AppRoutes.breakDetail, extra: t),
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _PlanError extends StatelessWidget {
  const _PlanError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Couldn't build your plan.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
```

> References `AppRoutes.breakDetail` + `context.push(..., extra: t)` from Task 5 — implement Task 5 before running this test (or temporarily add the route constant). Recommended: do Task 5's route wiring, then run this test.

- [ ] **Step 4: Run test to verify it passes** (after Task 5 route exists)

Run: `flutter test test/screens/plan/plan_screen_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**
```bash
git add lib/screens/plan/plan_screen.dart test/screens/plan/plan_screen_test.dart
git commit -m "feat(plan): implement length-buffet PlanScreen with states"
```

---

## Task 5: Break detail screen + route

**Files:**
- Create: `lib/screens/plan/break_detail_screen.dart`
- Modify: `lib/router/app_router.dart` (add `breakDetail` route taking a `PlanTrip` via `extra`)
- Test: `test/screens/plan/break_detail_test.dart`

- [ ] **Step 1: Write the failing test**

`test/screens/plan/break_detail_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/screens/plan/break_detail_screen.dart';

void main() {
  testWidgets('shows day-by-day rows and PTO summary', (tester) async {
    final trip = PlanTrip(
      breakStart: DateTime(2026, 9, 23),
      breakEnd: DateTime(2026, 9, 27),
      breakLength: 5,
      ptoDates: [DateTime(2026, 9, 23)],
      ptoCost: 1,
      anchors: const ['Chuseok'],
    );
    await tester.pumpWidget(MaterialApp(home: BreakDetailScreen(trip: trip)));
    expect(find.text('5-day break'), findsOneWidget);
    expect(find.textContaining('1 PTO'), findsOneWidget);
    // One row per day in the break (23,24,25,26,27 = 5 rows).
    expect(find.byKey(const ValueKey('break-day-row')), findsNWidgets(5));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/plan/break_detail_test.dart`
Expected: FAIL — undefined `BreakDetailScreen`.

- [ ] **Step 3: Implement the detail screen + route**

`lib/screens/plan/break_detail_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/models/plan_trip.dart';
import '../../theme/colors.dart';

class BreakDetailScreen extends StatelessWidget {
  const BreakDetailScreen({super.key, required this.trip});
  final PlanTrip trip;

  static const _weekend = {DateTime.saturday, DateTime.sunday};

  String _kindFor(DateTime day) {
    final isPto = trip.ptoDates.any((p) =>
        p.year == day.year && p.month == day.month && p.day == day.day);
    if (isPto) return 'PTO';
    if (_weekend.contains(day.weekday)) return 'Weekend';
    return 'Holiday';
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE MMM d');
    final days = <DateTime>[];
    for (var d = trip.breakStart;
        !d.isAfter(trip.breakEnd);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Break detail')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('${trip.breakLength}-day break',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${trip.ptoCost} PTO day${trip.ptoCost == 1 ? '' : 's'} → '
                '${trip.breakLength} days off',
                style: const TextStyle(color: DaysoffColors.neutral700)),
            const SizedBox(height: 20),
            for (final d in days)
              Container(
                key: const ValueKey('break-day-row'),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: DaysoffColors.neutral100)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(fmt.format(d))),
                    Text(_kindFor(d),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

Modify `lib/router/app_router.dart`: add the route constant and `GoRoute`. Add `breakDetail` to `AppRoutes`:
```dart
  static const breakDetail = '/plan/break';
```
Add the import and route entry (inside the `routes:` list of `appRouter`):
```dart
// at top with the other screen imports:
import '../screens/plan/break_detail_screen.dart';
import '../api/models/plan_trip.dart';

// inside routes: [ ... ]
    GoRoute(
      path: AppRoutes.breakDetail,
      builder: (context, state) =>
          BreakDetailScreen(trip: state.extra! as PlanTrip),
    ),
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/screens/plan/break_detail_test.dart test/screens/plan/plan_screen_test.dart`
Expected: PASS. Then run the FULL suite + analyzer:
Run: `flutter test && flutter analyze`
Expected: all tests pass; analyzer clean.

- [ ] **Step 5: Commit**
```bash
git add lib/screens/plan/break_detail_screen.dart lib/router/app_router.dart test/screens/plan/break_detail_test.dart
git commit -m "feat(plan): add break detail screen + route"
```

---

## Self-review

- **Coverage:** `/v1/plan` models w/ snake_case mapping ✓ (T1); ApiClient.getPlan + planProvider ✓ (T2); buffet widgets BreakCard/DayRibbon/PtoCostPill ✓ (T3); PlanScreen length buffet + loading/error/empty ✓ (T4); break detail + route ✓ (T5). Mirrors the Holidays feature's layering and the repo's Riverpod/go_router/freezed idiom.
- **Placeholder scan:** none — full code throughout. The only forward reference is T4→T5 (`AppRoutes.breakDetail`), explicitly called out with ordering guidance.
- **Type consistency:** `PlanTrip`(breakStart/breakEnd/breakLength/ptoDates/ptoCost/anchors), `PlanResponse`(...,resultsByLength), `ApiClient.getPlan({country,year,budget,minLength,maxLength})`, `PlanQuery`(country,year,budget,minLength,maxLength), `planProvider`, `BreakCard({trip,onTap})`, `PtoCostPill({cost})`, `DayRibbon({trip})`, `BreakDetailScreen({trip})`, `AppRoutes.breakDetail` — consistent across tasks.
- **Idiom:** tests use ProviderScope/ProviderContainer overrides (no mocktail), matching `test/widget_test.dart`. Codegen step included for freezed.

## Done when
`flutter test && flutter analyze` is clean, and from the running app (`flutter run --dart-define=API_BASE_URL=https://daysoff-api.fly.dev`) navigating to Plan shows the KR-2026 length buffet from the live API and tapping a card opens the break detail. (Offline → the error state with Retry, which is correct.)
