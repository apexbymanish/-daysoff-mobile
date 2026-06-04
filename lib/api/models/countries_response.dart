import 'package:freezed_annotation/freezed_annotation.dart';

import 'country.dart';

part 'countries_response.freezed.dart';
part 'countries_response.g.dart';

@freezed
class CountriesResponse with _$CountriesResponse {
  const factory CountriesResponse({
    required int count,
    required List<Country> countries,
  }) = _CountriesResponse;

  factory CountriesResponse.fromJson(Map<String, dynamic> json) =>
      _$CountriesResponseFromJson(json);
}
