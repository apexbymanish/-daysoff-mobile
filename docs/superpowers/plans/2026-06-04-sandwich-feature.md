# daysoff-mobile — Sandwich Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Flesh out the `sandwich_screen` stub into the sandwich-day detector — fetch `/v1/sandwiches` for KR 2026 and list single workdays wedged between off-days as dashed cards ("Take Mon May 4 off → 4-day break"), with loading/error/empty states.

**Architecture:** Mirror the Plan + Holidays features exactly. `freezed` models in `lib/api/models/` → `ApiClient.getSandwiches` (dio) → `sandwichesProvider` (`FutureProvider.family`) → `SandwichScreen` (`ConsumerWidget` with `.when`) + a `SandwichCard` widget. Reuses the existing `PtoCostPill` from the Plan feature. No new packages; tests use `ProviderScope`/`ProviderContainer` overrides (repo idiom).

**Tech Stack:** Flutter, flutter_riverpod, go_router (sandwich route already exists), dio, freezed + json_serializable, intl.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile` (package `daysoff_mobile`). Create and work on branch **`feat/sandwich-feature`** off `main` (commit there, never switch mid-task). Baseline green (Holidays + Plan merged to main; `flutter test` 11 pass, analyzer clean). The router already has a `sandwich` route pointing at `SandwichScreen`.

## Verified `/v1/sandwiches` contract (from daysoff-api `api/schemas.py`)

`GET /v1/sandwiches?country=KR&year=2026&workweek=sat,sun` →
```json
{
  "country": "KR", "year": 2026,
  "workweek": ["sat","sun"], "workweek_source": "default", "count": 1,
  "sandwiches": [{
    "pto_date": "2026-05-04", "weekday": "Monday",
    "break_start": "2026-05-02", "break_end": "2026-05-05",
    "break_length": 4, "pto_cost": 1,
    "context": "Weekend + Children's Day"
  }]
}
```
`workweek` query param is a comma list of OFF days (optional; backend defaults per country). JSON is snake_case → map with `@JsonKey(name: ...)`. `pto_date`/`break_start`/`break_end` are date strings → `DateTime`; `weekday`/`context` are strings.

## Existing patterns to follow (identical to the Plan feature)
- freezed model like `lib/api/models/plan_trip.dart` (snake_case via `@JsonKey`).
- `ApiClient` method like `getPlan` (dio GET + `Model.fromJson(res.data!)`).
- Provider like `lib/providers/plan_provider.dart` (`*Query` value class + `FutureProvider.family`).
- Screen like `lib/screens/plan/plan_screen.dart` (`ConsumerWidget` + `.when` loading/error(retry)/data, empty guard).
- Tests via ProviderScope/ProviderContainer overrides (no mocktail).
- Reuse `lib/screens/plan/widgets/pto_cost_pill.dart` (`PtoCostPill({cost})`) — a generic pill (acceptable cross-feature reuse; a future refactor may hoist it to a shared dir).
- The project's `analysis_options.yaml` already sets `invalid_annotation_target: ignore` for freezed `@JsonKey`.

## Out of scope
Workweek editing UI (use backend default), saving/reminders, "save this PTO day" action wiring (button is present but its onTap is a no-op placeholder this phase), country picker.

---

## File Structure

```
lib/api/models/sandwich_record.dart       (+ .freezed.dart + .g.dart via codegen)
lib/api/models/sandwiches_response.dart    (+ .freezed.dart + .g.dart via codegen)
lib/api/api_client.dart                    MODIFY: add getSandwiches()
lib/providers/sandwiches_provider.dart     SandwichesQuery + sandwichesProvider
lib/screens/sandwich/widgets/sandwich_card.dart
lib/screens/sandwich/sandwich_screen.dart  REPLACE stub: list + states
test/api/models/sandwich_models_test.dart
test/providers/sandwiches_provider_test.dart
test/screens/sandwich/sandwich_card_test.dart
test/screens/sandwich/sandwich_screen_test.dart
```

---

## Task 0: Create the feature branch

- [ ] **Step 1:** From the repo root, ensure you're on `main` and create the branch:
```bash
cd /Users/manishadhikari/Documents/Projects/daysoff-mobile
git checkout main
git checkout -b feat/sandwich-feature
git add docs/superpowers/plans/2026-06-04-sandwich-feature.md
git commit -m "docs: add Sandwich feature implementation plan"
```

---

## Task 1: Sandwich freezed models

**Files:**
- Create: `lib/api/models/sandwich_record.dart`, `lib/api/models/sandwiches_response.dart` (+ codegen)
- Test: `test/api/models/sandwich_models_test.dart`

- [ ] **Step 1: Write the failing test**

`test/api/models/sandwich_models_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/sandwich_record.dart';
import 'package:daysoff_mobile/api/models/sandwiches_response.dart';

void main() {
  const recJson = {
    'pto_date': '2026-05-04',
    'weekday': 'Monday',
    'break_start': '2026-05-02',
    'break_end': '2026-05-05',
    'break_length': 4,
    'pto_cost': 1,
    'context': 'Weekend + Children\'s Day',
  };

  test('SandwichRecord.fromJson maps snake_case + dates', () {
    final r = SandwichRecord.fromJson(recJson);
    expect(r.ptoDate, DateTime(2026, 5, 4));
    expect(r.weekday, 'Monday');
    expect(r.breakStart, DateTime(2026, 5, 2));
    expect(r.breakEnd, DateTime(2026, 5, 5));
    expect(r.breakLength, 4);
    expect(r.ptoCost, 1);
    expect(r.context, "Weekend + Children's Day");
  });

  test('SandwichesResponse.fromJson parses list + workweek', () {
    final resp = SandwichesResponse.fromJson({
      'country': 'KR',
      'year': 2026,
      'workweek': ['sat', 'sun'],
      'workweek_source': 'default',
      'count': 1,
      'sandwiches': [recJson],
    });
    expect(resp.country, 'KR');
    expect(resp.workweekSource, 'default');
    expect(resp.count, 1);
    expect(resp.sandwiches.single.ptoDate, DateTime(2026, 5, 4));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/api/models/sandwich_models_test.dart`
Expected: FAIL — model files/parts missing.

- [ ] **Step 3: Write the model sources**

`lib/api/models/sandwich_record.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sandwich_record.freezed.dart';
part 'sandwich_record.g.dart';

/// One sandwich-day suggestion from GET /v1/sandwiches.
@freezed
class SandwichRecord with _$SandwichRecord {
  const factory SandwichRecord({
    @JsonKey(name: 'pto_date') required DateTime ptoDate,
    required String weekday,
    @JsonKey(name: 'break_start') required DateTime breakStart,
    @JsonKey(name: 'break_end') required DateTime breakEnd,
    @JsonKey(name: 'break_length') required int breakLength,
    @JsonKey(name: 'pto_cost') required int ptoCost,
    required String context,
  }) = _SandwichRecord;

  factory SandwichRecord.fromJson(Map<String, dynamic> json) =>
      _$SandwichRecordFromJson(json);
}
```

`lib/api/models/sandwiches_response.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'sandwich_record.dart';

part 'sandwiches_response.freezed.dart';
part 'sandwiches_response.g.dart';

/// Top-level shape of GET /v1/sandwiches.
@freezed
class SandwichesResponse with _$SandwichesResponse {
  const factory SandwichesResponse({
    required String country,
    required int year,
    required List<String> workweek,
    @JsonKey(name: 'workweek_source') required String workweekSource,
    required int count,
    required List<SandwichRecord> sandwiches,
  }) = _SandwichesResponse;

  factory SandwichesResponse.fromJson(Map<String, dynamic> json) =>
      _$SandwichesResponseFromJson(json);
}
```

- [ ] **Step 4: Generate code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: writes 4 outputs (sandwich_record + sandwiches_response `.freezed.dart`/`.g.dart`), no errors.

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/api/models/sandwich_models_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit**
```bash
git add lib/api/models/sandwich_record.dart lib/api/models/sandwiches_response.dart lib/api/models/sandwich_record.freezed.dart lib/api/models/sandwich_record.g.dart lib/api/models/sandwiches_response.freezed.dart lib/api/models/sandwiches_response.g.dart test/api/models/sandwich_models_test.dart
git commit -m "feat(sandwich): add SandwichRecord + SandwichesResponse freezed models"
```

---

## Task 2: ApiClient.getSandwiches + sandwichesProvider

**Files:**
- Modify: `lib/api/api_client.dart` (add `getSandwiches`; add `import 'models/sandwiches_response.dart';`)
- Create: `lib/providers/sandwiches_provider.dart`
- Test: `test/providers/sandwiches_provider_test.dart`

- [ ] **Step 1: Write the failing test**

`test/providers/sandwiches_provider_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/sandwich_record.dart';
import 'package:daysoff_mobile/api/models/sandwiches_response.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/providers/sandwiches_provider.dart';

class _FakeApiClient extends ApiClient {
  @override
  Future<SandwichesResponse> getSandwiches({
    required String country,
    required int year,
    List<String>? workweek,
  }) async =>
      SandwichesResponse(
        country: country,
        year: year,
        workweek: const ['sat', 'sun'],
        workweekSource: 'default',
        count: 1,
        sandwiches: [
          SandwichRecord(
            ptoDate: DateTime(2026, 5, 4),
            weekday: 'Monday',
            breakStart: DateTime(2026, 5, 2),
            breakEnd: DateTime(2026, 5, 5),
            breakLength: 4,
            ptoCost: 1,
            context: "Weekend + Children's Day",
          ),
        ],
      );
}

void main() {
  test('sandwichesProvider returns the ApiClient result', () async {
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      sandwichesProvider(const SandwichesQuery(country: 'KR', year: 2026)).future,
    );

    expect(result.sandwiches.single.breakLength, 4);
  });

  test('SandwichesQuery value equality', () {
    expect(const SandwichesQuery(country: 'KR', year: 2026),
        const SandwichesQuery(country: 'KR', year: 2026));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/sandwiches_provider_test.dart`
Expected: FAIL — undefined `getSandwiches`/`sandwichesProvider`/`SandwichesQuery`.

- [ ] **Step 3: Implement getSandwiches + provider**

Append to the `ApiClient` class in `lib/api/api_client.dart` (after `getPlan`, before the closing brace), and add `import 'models/sandwiches_response.dart';` near the other model imports:
```dart
  Future<SandwichesResponse> getSandwiches({
    required String country,
    required int year,
    List<String>? workweek,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Endpoints.sandwiches,
      queryParameters: {
        'country': country,
        'year': year,
        if (workweek != null && workweek.isNotEmpty) 'workweek': workweek.join(','),
      },
    );
    return SandwichesResponse.fromJson(response.data!);
  }
```

`lib/providers/sandwiches_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models/sandwiches_response.dart';
import 'api_provider.dart';

/// Args for the sandwiches query.
class SandwichesQuery {
  const SandwichesQuery({required this.country, required this.year});

  final String country;
  final int year;

  @override
  bool operator ==(Object other) =>
      other is SandwichesQuery && other.country == country && other.year == year;

  @override
  int get hashCode => Object.hash(country, year);
}

/// Fetches /v1/sandwiches for a country + year (backend default workweek).
final sandwichesProvider =
    FutureProvider.family<SandwichesResponse, SandwichesQuery>((ref, q) {
  final api = ref.watch(apiClientProvider);
  return api.getSandwiches(country: q.country, year: q.year);
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/sandwiches_provider_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**
```bash
git add lib/api/api_client.dart lib/providers/sandwiches_provider.dart test/providers/sandwiches_provider_test.dart
git commit -m "feat(sandwich): add ApiClient.getSandwiches + sandwichesProvider"
```

---

## Task 3: SandwichCard widget

**Files:**
- Create: `lib/screens/sandwich/widgets/sandwich_card.dart`
- Test: `test/screens/sandwich/sandwich_card_test.dart`

- [ ] **Step 1: Write the failing test**

`test/screens/sandwich/sandwich_card_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/sandwich_record.dart';
import 'package:daysoff_mobile/screens/sandwich/widgets/sandwich_card.dart';

SandwichRecord _rec() => SandwichRecord(
      ptoDate: DateTime(2026, 5, 4),
      weekday: 'Monday',
      breakStart: DateTime(2026, 5, 2),
      breakEnd: DateTime(2026, 5, 5),
      breakLength: 4,
      ptoCost: 1,
      context: "Weekend + Children's Day",
    );

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('shows take-off line, break length, context and PTO pill',
      (tester) async {
    await tester.pumpWidget(_host(SandwichCard(record: _rec())));
    expect(find.textContaining('Take Monday'), findsOneWidget);
    expect(find.textContaining('4-day break'), findsOneWidget);
    expect(find.textContaining("Weekend + Children's Day"), findsOneWidget);
    expect(find.text('1 PTO'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/sandwich/sandwich_card_test.dart`
Expected: FAIL — undefined `SandwichCard`.

- [ ] **Step 3: Implement the widget**

`lib/screens/sandwich/widgets/sandwich_card.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../api/models/sandwich_record.dart';
import '../../../theme/colors.dart';
import '../../plan/widgets/pto_cost_pill.dart';

/// A single sandwich-day suggestion. Outlined card (dashed-border styling is
/// a future cosmetic enhancement) with a one-tap "save" affordance.
class SandwichCard extends StatelessWidget {
  const SandwichCard({super.key, required this.record});
  final SandwichRecord record;

  @override
  Widget build(BuildContext context) {
    final dayFmt = DateFormat('MMM d');
    final ptoLabel = '${record.weekday} ${dayFmt.format(record.ptoDate)}';
    final range = '${dayFmt.format(record.breakStart)}–${dayFmt.format(record.breakEnd)}';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DaysoffColors.creamSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DaysoffColors.sage, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text('Take $ptoLabel off',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600)),
              ),
              PtoCostPill(cost: record.ptoCost),
            ],
          ),
          const SizedBox(height: 6),
          Text('${record.context} → ${record.breakLength}-day break ($range)',
              style: const TextStyle(
                  fontSize: 13, color: DaysoffColors.neutral700)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {}, // save + remind: wired in a later phase
              icon: const Icon(Icons.bookmark_border, size: 18),
              label: const Text('Save + remind'),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/screens/sandwich/sandwich_card_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Commit**
```bash
git add lib/screens/sandwich/widgets/sandwich_card.dart test/screens/sandwich/sandwich_card_test.dart
git commit -m "feat(sandwich): add SandwichCard widget"
```

---

## Task 4: SandwichScreen (list + states)

**Files:**
- Replace: `lib/screens/sandwich/sandwich_screen.dart`
- Test: `test/screens/sandwich/sandwich_screen_test.dart`

- [ ] **Step 1: Write the failing test**

`test/screens/sandwich/sandwich_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/sandwich_record.dart';
import 'package:daysoff_mobile/api/models/sandwiches_response.dart';
import 'package:daysoff_mobile/providers/sandwiches_provider.dart';
import 'package:daysoff_mobile/screens/sandwich/sandwich_screen.dart';
import 'package:daysoff_mobile/screens/sandwich/widgets/sandwich_card.dart';

SandwichesResponse _resp(List<SandwichRecord> s) => SandwichesResponse(
      country: 'KR',
      year: 2026,
      workweek: const ['sat', 'sun'],
      workweekSource: 'default',
      count: s.length,
      sandwiches: s,
    );

SandwichRecord _rec() => SandwichRecord(
      ptoDate: DateTime(2026, 5, 4),
      weekday: 'Monday',
      breakStart: DateTime(2026, 5, 2),
      breakEnd: DateTime(2026, 5, 5),
      breakLength: 4,
      ptoCost: 1,
      context: "Weekend + Children's Day",
    );

void main() {
  const q = SandwichesQuery(country: 'KR', year: 2026);

  testWidgets('data state renders a SandwichCard', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [sandwichesProvider(q).overrideWith((ref) async => _resp([_rec()]))],
      child: const MaterialApp(home: SandwichScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(SandwichCard), findsOneWidget);
  });

  testWidgets('empty state shows a message', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [sandwichesProvider(q).overrideWith((ref) async => _resp([]))],
      child: const MaterialApp(home: SandwichScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('No sandwich days'), findsOneWidget);
  });

  testWidgets('error state shows Retry', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [sandwichesProvider(q).overrideWith((ref) async => throw Exception('x'))],
      child: const MaterialApp(home: SandwichScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/sandwich/sandwich_screen_test.dart`
Expected: FAIL — `SandwichScreen` is still the stub (no `SandwichCard`).

- [ ] **Step 3: Implement the screen**

Replace `lib/screens/sandwich/sandwich_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/sandwiches_response.dart';
import '../../providers/sandwiches_provider.dart';
import '../../theme/colors.dart';
import 'widgets/sandwich_card.dart';

class SandwichScreen extends ConsumerWidget {
  const SandwichScreen({super.key});

  static const _query = SandwichesQuery(country: 'KR', year: 2026);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sandwichesProvider(_query));
    return Scaffold(
      appBar: AppBar(title: const Text('Sandwich days')),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _SandwichError(
              onRetry: () => ref.invalidate(sandwichesProvider(_query))),
          data: (resp) => _SandwichList(response: resp),
        ),
      ),
    );
  }
}

class _SandwichList extends StatelessWidget {
  const _SandwichList({required this.response});
  final SandwichesResponse response;

  @override
  Widget build(BuildContext context) {
    if (response.sandwiches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No sandwich days this year.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: DaysoffColors.neutral700)),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Single workdays between days off — take one, gain a long weekend.',
            style: TextStyle(fontSize: 13, color: DaysoffColors.neutral700),
          ),
        ),
        for (final s in response.sandwiches) SandwichCard(record: s),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _SandwichError extends StatelessWidget {
  const _SandwichError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Couldn't load sandwich days.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test + full gate**

Run: `flutter test test/screens/sandwich/sandwich_screen_test.dart`
Expected: PASS (3 tests). Then the whole suite + analyzer:
Run: `flutter test && flutter analyze`
Expected: all tests pass; analyzer clean.

- [ ] **Step 5: Commit**
```bash
git add lib/screens/sandwich/sandwich_screen.dart test/screens/sandwich/sandwich_screen_test.dart
git commit -m "feat(sandwich): implement SandwichScreen with states"
```

---

## Self-review

- **Coverage:** models w/ snake_case + dates ✓ (T1); `getSandwiches` + provider ✓ (T2); `SandwichCard` ✓ (T3); `SandwichScreen` list + loading/error/empty ✓ (T4). Mirrors Plan/Holidays layering.
- **Placeholder scan:** none — full code throughout. (`SandwichCard`'s "Save + remind" onTap is an intentional no-op placeholder this phase, called out in the spec.)
- **Type consistency:** `SandwichRecord`(ptoDate/weekday/breakStart/breakEnd/breakLength/ptoCost/context), `SandwichesResponse`(...,sandwiches), `ApiClient.getSandwiches({country,year,workweek?})`, `SandwichesQuery`(country,year), `sandwichesProvider`, `SandwichCard({record})`, `SandwichScreen` — consistent across tasks.
- **Idiom:** ProviderScope/ProviderContainer overrides (no mocktail); reuses `PtoCostPill`; codegen step for freezed; `DaysoffColors` for all colors; `intl` for dates.

## Done when
`flutter test && flutter analyze` is clean, and from the running app the Sandwich tab/route shows KR-2026 sandwich-day cards from the live `/v1/sandwiches`. (Offline → error state with Retry.)
