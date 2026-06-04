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
