import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models/sandwiches_response.dart';
import 'api_provider.dart';

/// Args for the sandwiches query.
class SandwichesQuery {
  const SandwichesQuery({
    required this.country,
    required this.year,
    this.workweek = const [],
  });

  final String country;
  final int year;
  final List<String> workweek;

  @override
  bool operator ==(Object other) =>
      other is SandwichesQuery &&
      other.country == country &&
      other.year == year &&
      _listEq(other.workweek, workweek);

  @override
  int get hashCode => Object.hash(country, year, Object.hashAll(workweek));
}

bool _listEq(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Fetches /v1/sandwiches for a country + year + weekend.
final sandwichesProvider =
    FutureProvider.family<SandwichesResponse, SandwichesQuery>((ref, q) {
  final api = ref.watch(apiClientProvider);
  return api.getSandwiches(country: q.country, year: q.year, workweek: q.workweek);
});
