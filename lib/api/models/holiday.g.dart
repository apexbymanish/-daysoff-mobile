// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HolidayImpl _$$HolidayImplFromJson(Map<String, dynamic> json) =>
    _$HolidayImpl(
      date: DateTime.parse(json['date'] as String),
      name: json['name'] as String,
      source: json['source'] as String,
    );

Map<String, dynamic> _$$HolidayImplToJson(_$HolidayImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'name': instance.name,
      'source': instance.source,
    };
