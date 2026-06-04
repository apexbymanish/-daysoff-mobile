// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'countries_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CountriesResponseImpl _$$CountriesResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CountriesResponseImpl(
  count: (json['count'] as num).toInt(),
  countries: (json['countries'] as List<dynamic>)
      .map((e) => Country.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$CountriesResponseImplToJson(
  _$CountriesResponseImpl instance,
) => <String, dynamic>{
  'count': instance.count,
  'countries': instance.countries,
};
