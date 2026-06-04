# daysoff-mobile — Selectable Country + Year Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Make the app dynamic instead of hardcoded KR/2026 — add a searchable country picker (fed by `/v1/countries`) and a year stepper, backed by app-wide `selectedCountryProvider` / `selectedYearProvider` that Holidays, Plan, and Sandwich all read.

**Architecture:** Two Riverpod `StateProvider`s hold the selected country code + year (defaults `KR` / `2026`). A `Country` freezed model + `getCountries` + `countriesProvider` (FutureProvider) feed a full-screen `CountryPickerScreen` (search + pinned list) that writes `selectedCountryProvider` and pops. The three feature screens replace their hardcoded `static const` query args with `ref.watch(selectedCountryProvider)` / `selectedYearProvider`. Home gains a tappable country chip (→ picker) and a ◀ year ▶ stepper.

**Tech Stack:** Flutter, flutter_riverpod, go_router, dio, freezed. No new deps.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile` (package `daysoff_mobile`), branch **`feat/country-selection`** (commit there, never switch). Baseline green: Holidays+Plan+Sandwich+shell+Settings on main, 23 tests, analyzer clean.

## Verified `/v1/countries` contract (from daysoff-api `api/schemas.py`)
`GET /v1/countries` → `{ "count": N, "countries": [ { "code": "KR", "name": "South Korea", "news_enriched": true }, ... ] }` (250+ entries).

## Key constraint (keep existing tests green)
The selected defaults remain **KR / 2026**, so the feature screens' watched query stays `(country: 'KR', year: 2026)` by default — existing widget tests that override `holidaysProvider(HolidaysQuery(country:'KR',year:2026))` etc. continue to match. Do not change the defaults.

## Out of scope
Onboarding welcome flow, persisting the selection across launches, country-of-residence overlay, `/v1/compare`.

---

## File Structure

```
lib/api/models/country.dart                     NEW (+ codegen)
lib/api/models/countries_response.dart          NEW (+ codegen)
lib/api/api_client.dart                          MODIFY: add getCountries
lib/providers/countries_provider.dart            NEW (countriesProvider)
lib/providers/selection_provider.dart            NEW (selectedCountryProvider + selectedYearProvider)
lib/screens/country_picker/country_picker_screen.dart  NEW
lib/router/app_router.dart                        MODIFY: add /picker/country (root navigator)
lib/screens/home/home_screen.dart                 MODIFY: read selection; chip→picker; year stepper
lib/screens/plan/plan_screen.dart                 MODIFY: read selection in the query
lib/screens/sandwich/sandwich_screen.dart         MODIFY: read selection in the query
test/...                                          NEW + updates
```

---

## Task 0: Branch + commit plan
- [ ] From repo root (branch `feat/country-selection` already created): `git add docs/superpowers/plans/2026-06-04-country-selection.md && git commit -m "docs: add selectable country+year plan"`

---

## Task 1: Country models

**Files:** Create `lib/api/models/country.dart`, `lib/api/models/countries_response.dart` (+codegen); Test `test/api/models/country_models_test.dart`

- [ ] **Step 1: Failing test** — `test/api/models/country_models_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/country.dart';
import 'package:daysoff_mobile/api/models/countries_response.dart';

void main() {
  test('Country.fromJson maps news_enriched', () {
    final c = Country.fromJson(const {'code': 'KR', 'name': 'South Korea', 'news_enriched': true});
    expect(c.code, 'KR');
    expect(c.name, 'South Korea');
    expect(c.newsEnriched, true);
  });

  test('CountriesResponse.fromJson parses list', () {
    final r = CountriesResponse.fromJson(const {
      'count': 1,
      'countries': [{'code': 'KR', 'name': 'South Korea', 'news_enriched': true}],
    });
    expect(r.count, 1);
    expect(r.countries.single.code, 'KR');
  });
}
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/api/models/country_models_test.dart`

- [ ] **Step 3: Implement**

`lib/api/models/country.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'country.freezed.dart';
part 'country.g.dart';

@freezed
class Country with _$Country {
  const factory Country({
    required String code,
    required String name,
    @JsonKey(name: 'news_enriched') required bool newsEnriched,
  }) = _Country;

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);
}
```

`lib/api/models/countries_response.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'country.dart';

part 'countries_response.freezed.dart';
part 'countries_response.g.dart';

@freezed
class CountriesResponse with _$CountriesResponse {
  const factory CountriesResponse({
    required int count,
    required List<Country> countries,
  }) = _CountriesResponse;

  factory CountriesResponse.fromJson(Map<String, dynamic> json) =>
      _$CountriesResponseFromJson(json);
}
```

- [ ] **Step 4: Codegen** — `dart run build_runner build --delete-conflicting-outputs`
- [ ] **Step 5: Run → PASS** — `flutter test test/api/models/country_models_test.dart`
- [ ] **Step 6: Commit** — `git add lib/api/models/country* lib/api/models/countries_response* test/api/models/country_models_test.dart && git commit -m "feat(country): add Country + CountriesResponse models"`

---

## Task 2: getCountries + countriesProvider + selection providers

**Files:** Modify `lib/api/api_client.dart`; Create `lib/providers/countries_provider.dart`, `lib/providers/selection_provider.dart`; Test `test/providers/selection_provider_test.dart`, `test/providers/countries_provider_test.dart`

- [ ] **Step 1: Failing tests**

`test/providers/selection_provider_test.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/providers/selection_provider.dart';

void main() {
  test('defaults to KR / 2026 and updates', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(selectedCountryProvider), 'KR');
    expect(c.read(selectedYearProvider), 2026);
    c.read(selectedCountryProvider.notifier).state = 'NP';
    c.read(selectedYearProvider.notifier).state = 2027;
    expect(c.read(selectedCountryProvider), 'NP');
    expect(c.read(selectedYearProvider), 2027);
  });
}
```

`test/providers/countries_provider_test.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/countries_response.dart';
import 'package:daysoff_mobile/api/models/country.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/providers/countries_provider.dart';

class _FakeApi extends ApiClient {
  @override
  Future<CountriesResponse> getCountries() async => const CountriesResponse(
        count: 1,
        countries: [Country(code: 'KR', name: 'South Korea', newsEnriched: true)],
      );
}

void main() {
  test('countriesProvider returns the ApiClient list', () async {
    final c = ProviderContainer(overrides: [apiClientProvider.overrideWithValue(_FakeApi())]);
    addTearDown(c.dispose);
    final list = await c.read(countriesProvider.future);
    expect(list.single.code, 'KR');
  });
}
```

- [ ] **Step 2: Run → FAIL**

- [ ] **Step 3: Implement**

Append to `ApiClient` (and `import 'models/countries_response.dart';`):
```dart
  Future<CountriesResponse> getCountries() async {
    final response = await _dio.get<Map<String, dynamic>>(Endpoints.countries);
    return CountriesResponse.fromJson(response.data!);
  }
```

`lib/providers/selection_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide selected work country (ISO-2) and year. Defaults to the
/// KR / 2026 sample so the app shows data on first launch.
final selectedCountryProvider = StateProvider<String>((ref) => 'KR');
final selectedYearProvider = StateProvider<int>((ref) => 2026);
```

`lib/providers/countries_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models/country.dart';
import 'api_provider.dart';

/// Fetches the full /v1/countries list once.
final countriesProvider = FutureProvider<List<Country>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final resp = await api.getCountries();
  return resp.countries;
});
```

- [ ] **Step 4: Run → PASS**
- [ ] **Step 5: Commit** — `git add lib/api/api_client.dart lib/providers/countries_provider.dart lib/providers/selection_provider.dart test/providers/selection_provider_test.dart test/providers/countries_provider_test.dart && git commit -m "feat(country): add getCountries, countriesProvider, selection providers"`

---

## Task 3: CountryPickerScreen + route

**Files:** Create `lib/screens/country_picker/country_picker_screen.dart`; Modify `lib/router/app_router.dart`; Test `test/screens/country_picker/country_picker_screen_test.dart`

- [ ] **Step 1: Failing test**

`test/screens/country_picker/country_picker_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/country.dart';
import 'package:daysoff_mobile/providers/countries_provider.dart';
import 'package:daysoff_mobile/providers/selection_provider.dart';
import 'package:daysoff_mobile/screens/country_picker/country_picker_screen.dart';

void main() {
  testWidgets('tapping a country sets selectedCountryProvider', (tester) async {
    final container = ProviderContainer(overrides: [
      countriesProvider.overrideWith((ref) async => const [
            Country(code: 'KR', name: 'South Korea', newsEnriched: true),
            Country(code: 'NP', name: 'Nepal', newsEnriched: false),
          ]),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: CountryPickerScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nepal'));
    await tester.pumpAndSettle();

    expect(container.read(selectedCountryProvider), 'NP');
  });

  testWidgets('search filters the list', (tester) async {
    final container = ProviderContainer(overrides: [
      countriesProvider.overrideWith((ref) async => const [
            Country(code: 'KR', name: 'South Korea', newsEnriched: true),
            Country(code: 'JP', name: 'Japan', newsEnriched: false),
          ]),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: CountryPickerScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'jap');
    await tester.pumpAndSettle();
    expect(find.text('Japan'), findsOneWidget);
    expect(find.text('South Korea'), findsNothing);
  });
}
```

- [ ] **Step 2: Run → FAIL**

- [ ] **Step 3: Implement**

`lib/screens/country_picker/country_picker_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/country.dart';
import '../../providers/countries_provider.dart';
import '../../providers/selection_provider.dart';
import '../../theme/colors.dart';

class CountryPickerScreen extends ConsumerStatefulWidget {
  const CountryPickerScreen({super.key});
  @override
  ConsumerState<CountryPickerScreen> createState() => _CountryPickerScreenState();
}

class _CountryPickerScreenState extends ConsumerState<CountryPickerScreen> {
  static const _pinned = {'KR', 'NP', 'JP', 'IN', 'PH'};
  String _query = '';

  List<Country> _filter(List<Country> all) {
    final q = _query.trim().toLowerCase();
    final matches = q.isEmpty
        ? all
        : all.where((c) =>
            c.name.toLowerCase().contains(q) || c.code.toLowerCase().contains(q));
    final list = matches.toList()
      ..sort((a, b) {
        final ap = _pinned.contains(a.code) ? 0 : 1;
        final bp = _pinned.contains(b.code) ? 0 : 1;
        if (ap != bp) return ap - bp;
        return a.name.compareTo(b.name);
      });
    return list;
  }

  void _select(Country c) {
    ref.read(selectedCountryProvider.notifier).state = c.code;
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(countriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Where do you work?')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search 250+ countries',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(countriesProvider),
                    child: const Text('Retry'),
                  ),
                ),
                data: (all) {
                  final list = _filter(all);
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final c = list[i];
                      return ListTile(
                        title: Text(c.name),
                        trailing: Text(c.code,
                            style: const TextStyle(color: DaysoffColors.neutral500)),
                        onTap: () => _select(c),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

In `lib/router/app_router.dart`: add `static const countryPicker = '/picker/country';` to `AppRoutes`, import `CountryPickerScreen`, and add a top-level route (outside the shell, on the root navigator so it covers the nav bar):
```dart
    GoRoute(
      path: AppRoutes.countryPicker,
      builder: (context, state) => const CountryPickerScreen(),
    ),
```
(Place it as a sibling of the `StatefulShellRoute` and the onboarding route, inside the top-level `routes:` list. The root navigator is already the default for top-level routes.)

- [ ] **Step 4: Run → PASS** — `flutter test test/screens/country_picker/country_picker_screen_test.dart`
- [ ] **Step 5: Commit** — `git add lib/screens/country_picker lib/router/app_router.dart test/screens/country_picker/country_picker_screen_test.dart && git commit -m "feat(country): add searchable CountryPickerScreen + route"`

---

## Task 4: Wire selection into Home / Plan / Sandwich

**Files:** Modify `lib/screens/home/home_screen.dart`, `lib/screens/plan/plan_screen.dart`, `lib/screens/sandwich/sandwich_screen.dart`; Test `test/screens/home/home_selection_test.dart`

This task edits existing screens — READ each file first and make the minimal change: replace the hardcoded `country`/`year` query args with values read from `selectedCountryProvider` / `selectedYearProvider`. Keep defaults KR/2026 so existing tests still match.

- [ ] **Step 1: Failing test** — `test/screens/home/home_selection_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/providers/holidays_provider.dart';
import 'package:daysoff_mobile/providers/selection_provider.dart';
import 'package:daysoff_mobile/screens/home/home_screen.dart';

void main() {
  testWidgets('Home queries holidays for the SELECTED country/year', (tester) async {
    var askedCountry = '';
    var askedYear = 0;
    final container = ProviderContainer(overrides: [
      // selected = NP / 2027
      selectedCountryProvider.overrideWith((ref) => 'NP'),
      selectedYearProvider.overrideWith((ref) => 2027),
      holidaysProvider(const HolidaysQuery(country: 'NP', year: 2027)).overrideWith((ref) async {
        askedCountry = 'NP';
        askedYear = 2027;
        return const HolidaysResponse(country: 'NP', year: 2027, count: 0, holidays: []);
      }),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: GoRouter(routes: [
          GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        ]),
      ),
    ));
    await tester.pumpAndSettle();

    expect(askedCountry, 'NP');
    expect(askedYear, 2027);
  });
}
```

- [ ] **Step 2: Run → FAIL** (Home still queries the hardcoded KR/2026, so the NP/2027 override is never hit → `askedCountry` stays empty).

- [ ] **Step 3: Implement**

In `home_screen.dart`: remove the `static const _country`/`_year`; in `build`, read `final country = ref.watch(selectedCountryProvider); final year = ref.watch(selectedYearProvider);` and use them in the `holidaysProvider(HolidaysQuery(country: country, year: year))` watch + the error-retry invalidate. Make the header **country chip** an `InkWell` that calls `context.push('/picker/country')` (import go_router + AppRoutes; use `AppRoutes.countryPicker`), and render the chip's code/flag + the year from the selected values. Add a small **year stepper** (◀ {year} ▶) whose buttons do `ref.read(selectedYearProvider.notifier).state += / -= 1`. (Flag emoji: keep the existing `🇰🇷` only when country=='KR'; otherwise show a generic 🌐 or no flag — minimal.)

In `plan_screen.dart`: replace `static const _query = PlanQuery(country:'KR', year:2026, budget:15)` usage — in `build`, read selected country/year and build `PlanQuery(country: country, year: year, budget: 15)`; use it in the watch + invalidate.

In `sandwich_screen.dart`: same — read selected country/year, build `SandwichesQuery(country: country, year: year)` in `build`; use in watch + invalidate.

Keep all three screens as `ConsumerWidget` (they already are). Because defaults are KR/2026, the existing `plan_screen_test`, `sandwich_screen_test`, `home`/`widget_test`, `app_shell_test` overrides (which use KR/2026 queries) still match.

- [ ] **Step 4: Run the failing test → PASS, then the FULL gate**

Run: `flutter test test/screens/home/home_selection_test.dart`
Expected: PASS. Then:
Run: `flutter test && flutter analyze`
Expected: ALL tests pass (existing KR/2026 overrides still match the defaults), analyzer clean. Fix any breakage (most likely: a test that pumped a screen without a `selectedCountryProvider` available — it has a default, so no override needed; or a missing import).

- [ ] **Step 5: Commit** — `git add lib/screens/home/home_screen.dart lib/screens/plan/plan_screen.dart lib/screens/sandwich/sandwich_screen.dart test/screens/home/home_selection_test.dart && git commit -m "feat(country): wire selected country/year into Home, Plan, Sandwich"`

---

## Self-review
- **Coverage:** Country models ✓ (T1); getCountries + countriesProvider + selection StateProviders ✓ (T2); searchable picker + route ✓ (T3); wiring into all three feature screens + Home chip/year-stepper ✓ (T4).
- **Placeholder scan:** none — full code for new pieces; T4 gives precise edit instructions against files the implementer reads (existing screens).
- **Type consistency:** `Country`(code/name/newsEnriched), `CountriesResponse`(count/countries), `ApiClient.getCountries()`, `countriesProvider` (`FutureProvider<List<Country>>`), `selectedCountryProvider`/`selectedYearProvider` (StateProviders), `CountryPickerScreen`, `AppRoutes.countryPicker='/picker/country'`. Feature screens build their existing `HolidaysQuery`/`PlanQuery`/`SandwichesQuery` from the selected values.
- **Test-safety:** defaults stay KR/2026 → existing overrides still match.

## Done when
`flutter test && flutter analyze` clean; running the app, the Home country chip opens a searchable picker, choosing a country (and stepping the year) re-queries Holidays/Plan/Sandwich for the new selection live.
