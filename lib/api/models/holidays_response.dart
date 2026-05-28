import 'package:freezed_annotation/freezed_annotation.dart';

import 'holiday.dart';

part 'holidays_response.freezed.dart';
part 'holidays_response.g.dart';

/// Top-level shape of GET /v1/holidays?country=...&year=...
@freezed
class HolidaysResponse with _$HolidaysResponse {
  const factory HolidaysResponse({
    required String country,
    required int year,
    required int count,
    required List<Holiday> holidays,
  }) = _HolidaysResponse;

  factory HolidaysResponse.fromJson(Map<String, dynamic> json) =>
      _$HolidaysResponseFromJson(json);
}
