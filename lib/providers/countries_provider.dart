import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models/country.dart';
import 'api_provider.dart';

/// Fetches the full /v1/countries list once.
final countriesProvider = FutureProvider<List<Country>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final resp = await api.getCountries();
  return resp.countries;
});
