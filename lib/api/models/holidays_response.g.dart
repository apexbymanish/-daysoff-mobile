// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holidays_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HolidaysResponseImpl _$$HolidaysResponseImplFromJson(
  Map<String, dynamic> json,
) => _$HolidaysResponseImpl(
  country: json['country'] as String,
  year: (json['year'] as num).toInt(),
  count: (json['count'] as num).toInt(),
  holidays: (json['holidays'] as List<dynamic>)
      .map((e) => Holiday.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$HolidaysResponseImplToJson(
  _$HolidaysResponseImpl instance,
) => <String, dynamic>{
  'country': instance.country,
  'year': instance.year,
  'count': instance.count,
  'holidays': instance.holidays,
};
