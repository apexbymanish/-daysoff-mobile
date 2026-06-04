// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanTripImpl _$$PlanTripImplFromJson(Map<String, dynamic> json) =>
    _$PlanTripImpl(
      breakStart: DateTime.parse(json['break_start'] as String),
      breakEnd: DateTime.parse(json['break_end'] as String),
      breakLength: (json['break_length'] as num).toInt(),
      ptoDates: (json['pto_dates'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      ptoCost: (json['pto_cost'] as num).toInt(),
      anchors: (json['anchors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$PlanTripImplToJson(_$PlanTripImpl instance) =>
    <String, dynamic>{
      'break_start': instance.breakStart.toIso8601String(),
      'break_end': instance.breakEnd.toIso8601String(),
      'break_length': instance.breakLength,
      'pto_dates': instance.ptoDates.map((e) => e.toIso8601String()).toList(),
      'pto_cost': instance.ptoCost,
      'anchors': instance.anchors,
    };
