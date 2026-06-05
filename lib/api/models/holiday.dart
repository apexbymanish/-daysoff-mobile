import 'package:freezed_annotation/freezed_annotation.dart';

part 'holiday.freezed.dart';
part 'holiday.g.dart';

/// One holiday record as returned by GET /v1/holidays.
@freezed
class Holiday with _$Holiday {
  const factory Holiday({
    required DateTime date,
    required String name,
    @JsonKey(name: 'name_local') String? nameLocal,
    required String source,
  }) = _Holiday;

  factory Holiday.fromJson(Map<String, dynamic> json) =>
      _$HolidayFromJson(json);
}
