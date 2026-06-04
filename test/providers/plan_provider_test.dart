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
