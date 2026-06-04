import 'package:dio/dio.dart';

import 'endpoints.dart';
import 'models/countries_response.dart';
import 'models/holidays_response.dart';
import 'models/plan_response.dart';
import 'models/sandwiches_response.dart';

/// Thin dio wrapper for the daysoff-api.
///
/// Base URL comes from --dart-define=API_BASE_URL=http://host:port
/// and defaults to localhost:8080 when not provided.
class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: const String.fromEnvironment(
                  'API_BASE_URL',
                  defaultValue: 'http://127.0.0.1:8080',
                ),
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 12),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;

  Future<HolidaysResponse> getHolidays({
    required String country,
    required int year,
    bool fromToday = false,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Endpoints.holidays,
      queryParameters: {
        'country': country,
        'year': year,
        if (fromToday) 'from_today': true,
      },
    );
    return HolidaysResponse.fromJson(response.data!);
  }

  Future<PlanResponse> getPlan({
    required String country,
    required int year,
    int budget = 15,
    int minLength = 3,
    int maxLength = 10,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Endpoints.plan,
      queryParameters: {
        'country': country,
        'year': year,
        'budget': budget,
        'min_length': minLength,
        'max_length': maxLength,
      },
    );
    return PlanResponse.fromJson(response.data!);
  }

  Future<SandwichesResponse> getSandwiches({
    required String country,
    required int year,
    List<String>? workweek,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Endpoints.sandwiches,
      queryParameters: {
        'country': country,
        'year': year,
        if (workweek != null && workweek.isNotEmpty) 'workweek': workweek.join(','),
      },
    );
    return SandwichesResponse.fromJson(response.data!);
  }

  Future<CountriesResponse> getCountries() async {
    final response = await _dio.get<Map<String, dynamic>>(Endpoints.countries);
    return CountriesResponse.fromJson(response.data!);
  }
}
