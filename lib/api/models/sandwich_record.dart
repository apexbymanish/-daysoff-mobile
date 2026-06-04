import 'package:freezed_annotation/freezed_annotation.dart';

part 'sandwich_record.freezed.dart';
part 'sandwich_record.g.dart';

/// One sandwich-day suggestion from GET /v1/sandwiches.
@freezed
class SandwichRecord with _$SandwichRecord {
  const factory SandwichRecord({
    @JsonKey(name: 'pto_date') required DateTime ptoDate,
    required String weekday,
    @JsonKey(name: 'break_start') required DateTime breakStart,
    @JsonKey(name: 'break_end') required DateTime breakEnd,
    @JsonKey(name: 'break_length') required int breakLength,
    @JsonKey(name: 'pto_cost') required int ptoCost,
    required String context,
  }) = _SandwichRecord;

  factory SandwichRecord.fromJson(Map<String, dynamic> json) =>
      _$SandwichRecordFromJson(json);
}
