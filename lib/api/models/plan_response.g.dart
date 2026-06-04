// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanResponseImpl _$$PlanResponseImplFromJson(Map<String, dynamic> json) =>
    _$PlanResponseImpl(
      country: json['country'] as String,
      year: (json['year'] as num).toInt(),
      budget: (json['budget'] as num).toInt(),
      workweek: (json['workweek'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      workweekSource: json['workweek_source'] as String,
      resultsByLength: (json['results_by_length'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => PlanTrip.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
    );

Map<String, dynamic> _$$PlanResponseImplToJson(_$PlanResponseImpl instance) =>
    <String, dynamic>{
      'country': instance.country,
      'year': instance.year,
      'budget': instance.budget,
      'workweek': instance.workweek,
      'workweek_source': instance.workweekSource,
      'results_by_length': instance.resultsByLength,
    };
