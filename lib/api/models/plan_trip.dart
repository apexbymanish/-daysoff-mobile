import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_trip.freezed.dart';
part 'plan_trip.g.dart';

/// One suggested break from GET /v1/plan (an item of results_by_length).
@freezed
class PlanTrip with _$PlanTrip {
  const factory PlanTrip({
    @JsonKey(name: 'break_start') required DateTime breakStart,
    @JsonKey(name: 'break_end') required DateTime breakEnd,
    @JsonKey(name: 'break_length') required int breakLength,
    @JsonKey(name: 'pto_dates') required List<DateTime> ptoDates,
    @JsonKey(name: 'pto_cost') required int ptoCost,
    required List<String> anchors,
  }) = _PlanTrip;

  factory PlanTrip.fromJson(Map<String, dynamic> json) =>
      _$PlanTripFromJson(json);
}
