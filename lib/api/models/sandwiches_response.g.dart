// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sandwiches_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SandwichesResponseImpl _$$SandwichesResponseImplFromJson(
  Map<String, dynamic> json,
) => _$SandwichesResponseImpl(
  country: json['country'] as String,
  year: (json['year'] as num).toInt(),
  workweek: (json['workweek'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  workweekSource: json['workweek_source'] as String,
  count: (json['count'] as num).toInt(),
  sandwiches: (json['sandwiches'] as List<dynamic>)
      .map((e) => SandwichRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$SandwichesResponseImplToJson(
  _$SandwichesResponseImpl instance,
) => <String, dynamic>{
  'country': instance.country,
  'year': instance.year,
  'workweek': instance.workweek,
  'workweek_source': instance.workweekSource,
  'count': instance.count,
  'sandwiches': instance.sandwiches,
};
