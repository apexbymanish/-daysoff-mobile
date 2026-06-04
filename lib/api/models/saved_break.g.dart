// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_break.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavedBreakImpl _$$SavedBreakImplFromJson(Map<String, dynamic> json) =>
    _$SavedBreakImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      ptoCost: (json['ptoCost'] as num).toInt(),
      kind: json['kind'] as String,
    );

Map<String, dynamic> _$$SavedBreakImplToJson(_$SavedBreakImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'ptoCost': instance.ptoCost,
      'kind': instance.kind,
    };
