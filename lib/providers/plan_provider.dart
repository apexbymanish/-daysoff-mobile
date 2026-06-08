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
    this.month,
    this.workweek = const [],
  });

  final String country;
  final int year;
  final int budget;
  final int minLength;
  final int maxLength;

  /// When set (1..12), the backend anchors results to breaks starting in this
  /// month; null requests the global best-per-length menu.
  final int? month;
  final List<String> workweek;

  @override
  bool operator ==(Object other) =>
      other is PlanQuery &&
      other.country == country &&
      other.year == year &&
      other.budget == budget &&
      other.minLength == minLength &&
      other.maxLength == maxLength &&
      other.month == month &&
      _listEq(other.workweek, workweek);

  @override
  int get hashCode => Object.hash(
      country, year, budget, minLength, maxLength, month, Object.hashAll(workweek));
}

bool _listEq(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
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
    month: q.month,
    workweek: q.workweek,
  );
});
