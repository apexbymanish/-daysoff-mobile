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
    int? budget,
    int? minLength,
    int? maxLength,
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
