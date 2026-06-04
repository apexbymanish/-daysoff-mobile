import 'package:freezed_annotation/freezed_annotation.dart';

import 'plan_trip.dart';

part 'plan_response.freezed.dart';
part 'plan_response.g.dart';

/// Top-level shape of GET /v1/plan.
@freezed
class PlanResponse with _$PlanResponse {
  const factory PlanResponse({
    required String country,
    required int year,
    required int budget,
    required List<String> workweek,
    @JsonKey(name: 'workweek_source') required String workweekSource,
    @JsonKey(name: 'results_by_length')
    required Map<String, List<PlanTrip>> resultsByLength,
  }) = _PlanResponse;

  factory PlanResponse.fromJson(Map<String, dynamic> json) =>
      _$PlanResponseFromJson(json);
}
