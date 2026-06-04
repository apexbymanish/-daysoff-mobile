import 'package:freezed_annotation/freezed_annotation.dart';

import 'sandwich_record.dart';

part 'sandwiches_response.freezed.dart';
part 'sandwiches_response.g.dart';

/// Top-level shape of GET /v1/sandwiches.
@freezed
class SandwichesResponse with _$SandwichesResponse {
  const factory SandwichesResponse({
    required String country,
    required int year,
    required List<String> workweek,
    @JsonKey(name: 'workweek_source') required String workweekSource,
    required int count,
    required List<SandwichRecord> sandwiches,
  }) = _SandwichesResponse;

  factory SandwichesResponse.fromJson(Map<String, dynamic> json) =>
      _$SandwichesResponseFromJson(json);
}
