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
