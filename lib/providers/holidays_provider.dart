import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models/holidays_response.dart';
import 'api_provider.dart';

/// Args for the holidays query.
class HolidaysQuery {
  const HolidaysQuery({required this.country, required this.year});

  final String country;
  final int year;

  @override
  bool operator ==(Object other) =>
      other is HolidaysQuery && other.country == country && other.year == year;

  @override
  int get hashCode => Object.hash(country, year);
}

/// Fetches /v1/holidays for a given country + year.
final holidaysProvider =
    FutureProvider.family<HolidaysResponse, HolidaysQuery>((ref, query) {
  final api = ref.watch(apiClientProvider);
  return api.getHolidays(country: query.country, year: query.year);
});
