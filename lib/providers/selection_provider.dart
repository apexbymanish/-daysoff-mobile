import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide selected work country (ISO-2) and year. Defaults to the
/// KR / 2026 sample so the app shows data on first launch.
final selectedCountryProvider = StateProvider<String>((ref) => 'KR');
final selectedYearProvider = StateProvider<int>((ref) => 2026);
