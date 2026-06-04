// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sandwich_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SandwichRecordImpl _$$SandwichRecordImplFromJson(Map<String, dynamic> json) =>
    _$SandwichRecordImpl(
      ptoDate: DateTime.parse(json['pto_date'] as String),
      weekday: json['weekday'] as String,
      breakStart: DateTime.parse(json['break_start'] as String),
      breakEnd: DateTime.parse(json['break_end'] as String),
      breakLength: (json['break_length'] as num).toInt(),
      ptoCost: (json['pto_cost'] as num).toInt(),
      context: json['context'] as String,
    );

Map<String, dynamic> _$$SandwichRecordImplToJson(
  _$SandwichRecordImpl instance,
) => <String, dynamic>{
  'pto_date': instance.ptoDate.toIso8601String(),
  'weekday': instance.weekday,
  'break_start': instance.breakStart.toIso8601String(),
  'break_end': instance.breakEnd.toIso8601String(),
  'break_length': instance.breakLength,
  'pto_cost': instance.ptoCost,
  'context': instance.context,
};
