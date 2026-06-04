import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_break.freezed.dart';
part 'saved_break.g.dart';

@freezed
class SavedBreak with _$SavedBreak {
  const factory SavedBreak({
    required String id,
    required String label,
    required DateTime start,
    required DateTime end,
    required int ptoCost,
    required String kind, // 'break' | 'sandwich'
  }) = _SavedBreak;

  factory SavedBreak.fromJson(Map<String, dynamic> json) =>
      _$SavedBreakFromJson(json);
}
