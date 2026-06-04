// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlanTrip _$PlanTripFromJson(Map<String, dynamic> json) {
  return _PlanTrip.fromJson(json);
}

/// @nodoc
mixin _$PlanTrip {
  @JsonKey(name: 'break_start')
  DateTime get breakStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'break_end')
  DateTime get breakEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'break_length')
  int get breakLength => throw _privateConstructorUsedError;
  @JsonKey(name: 'pto_dates')
  List<DateTime> get ptoDates => throw _privateConstructorUsedError;
  @JsonKey(name: 'pto_cost')
  int get ptoCost => throw _privateConstructorUsedError;
  List<String> get anchors => throw _privateConstructorUsedError;

  /// Serializes this PlanTrip to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanTrip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanTripCopyWith<PlanTrip> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanTripCopyWith<$Res> {
  factory $PlanTripCopyWith(PlanTrip value, $Res Function(PlanTrip) then) =
      _$PlanTripCopyWithImpl<$Res, PlanTrip>;
  @useResult
  $Res call({
    @JsonKey(name: 'break_start') DateTime breakStart,
    @JsonKey(name: 'break_end') DateTime breakEnd,
    @JsonKey(name: 'break_length') int breakLength,
    @JsonKey(name: 'pto_dates') List<DateTime> ptoDates,
    @JsonKey(name: 'pto_cost') int ptoCost,
    List<String> anchors,
  });
}

/// @nodoc
class _$PlanTripCopyWithImpl<$Res, $Val extends PlanTrip>
    implements $PlanTripCopyWith<$Res> {
  _$PlanTripCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanTrip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? breakStart = null,
    Object? breakEnd = null,
    Object? breakLength = null,
    Object? ptoDates = null,
    Object? ptoCost = null,
    Object? anchors = null,
  }) {
    return _then(
      _value.copyWith(
            breakStart: null == breakStart
                ? _value.breakStart
                : breakStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            breakEnd: null == breakEnd
                ? _value.breakEnd
                : breakEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            breakLength: null == breakLength
                ? _value.breakLength
                : breakLength // ignore: cast_nullable_to_non_nullable
                      as int,
            ptoDates: null == ptoDates
                ? _value.ptoDates
                : ptoDates // ignore: cast_nullable_to_non_nullable
                      as List<DateTime>,
            ptoCost: null == ptoCost
                ? _value.ptoCost
                : ptoCost // ignore: cast_nullable_to_non_nullable
                      as int,
            anchors: null == anchors
                ? _value.anchors
                : anchors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlanTripImplCopyWith<$Res>
    implements $PlanTripCopyWith<$Res> {
  factory _$$PlanTripImplCopyWith(
    _$PlanTripImpl value,
    $Res Function(_$PlanTripImpl) then,
  ) = __$$PlanTripImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'break_start') DateTime breakStart,
    @JsonKey(name: 'break_end') DateTime breakEnd,
    @JsonKey(name: 'break_length') int breakLength,
    @JsonKey(name: 'pto_dates') List<DateTime> ptoDates,
    @JsonKey(name: 'pto_cost') int ptoCost,
    List<String> anchors,
  });
}

/// @nodoc
class __$$PlanTripImplCopyWithImpl<$Res>
    extends _$PlanTripCopyWithImpl<$Res, _$PlanTripImpl>
    implements _$$PlanTripImplCopyWith<$Res> {
  __$$PlanTripImplCopyWithImpl(
    _$PlanTripImpl _value,
    $Res Function(_$PlanTripImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlanTrip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? breakStart = null,
    Object? breakEnd = null,
    Object? breakLength = null,
    Object? ptoDates = null,
    Object? ptoCost = null,
    Object? anchors = null,
  }) {
    return _then(
      _$PlanTripImpl(
        breakStart: null == breakStart
            ? _value.breakStart
            : breakStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        breakEnd: null == breakEnd
            ? _value.breakEnd
            : breakEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        breakLength: null == breakLength
            ? _value.breakLength
            : breakLength // ignore: cast_nullable_to_non_nullable
                  as int,
        ptoDates: null == ptoDates
            ? _value._ptoDates
            : ptoDates // ignore: cast_nullable_to_non_nullable
                  as List<DateTime>,
        ptoCost: null == ptoCost
            ? _value.ptoCost
            : ptoCost // ignore: cast_nullable_to_non_nullable
                  as int,
        anchors: null == anchors
            ? _value._anchors
            : anchors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanTripImpl implements _PlanTrip {
  const _$PlanTripImpl({
    @JsonKey(name: 'break_start') required this.breakStart,
    @JsonKey(name: 'break_end') required this.breakEnd,
    @JsonKey(name: 'break_length') required this.breakLength,
    @JsonKey(name: 'pto_dates') required final List<DateTime> ptoDates,
    @JsonKey(name: 'pto_cost') required this.ptoCost,
    required final List<String> anchors,
  }) : _ptoDates = ptoDates,
       _anchors = anchors;

  factory _$PlanTripImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanTripImplFromJson(json);

  @override
  @JsonKey(name: 'break_start')
  final DateTime breakStart;
  @override
  @JsonKey(name: 'break_end')
  final DateTime breakEnd;
  @override
  @JsonKey(name: 'break_length')
  final int breakLength;
  final List<DateTime> _ptoDates;
  @override
  @JsonKey(name: 'pto_dates')
  List<DateTime> get ptoDates {
    if (_ptoDates is EqualUnmodifiableListView) return _ptoDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ptoDates);
  }

  @override
  @JsonKey(name: 'pto_cost')
  final int ptoCost;
  final List<String> _anchors;
  @override
  List<String> get anchors {
    if (_anchors is EqualUnmodifiableListView) return _anchors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_anchors);
  }

  @override
  String toString() {
    return 'PlanTrip(breakStart: $breakStart, breakEnd: $breakEnd, breakLength: $breakLength, ptoDates: $ptoDates, ptoCost: $ptoCost, anchors: $anchors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanTripImpl &&
            (identical(other.breakStart, breakStart) ||
                other.breakStart == breakStart) &&
            (identical(other.breakEnd, breakEnd) ||
                other.breakEnd == breakEnd) &&
            (identical(other.breakLength, breakLength) ||
                other.breakLength == breakLength) &&
            const DeepCollectionEquality().equals(other._ptoDates, _ptoDates) &&
            (identical(other.ptoCost, ptoCost) || other.ptoCost == ptoCost) &&
            const DeepCollectionEquality().equals(other._anchors, _anchors));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    breakStart,
    breakEnd,
    breakLength,
    const DeepCollectionEquality().hash(_ptoDates),
    ptoCost,
    const DeepCollectionEquality().hash(_anchors),
  );

  /// Create a copy of PlanTrip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanTripImplCopyWith<_$PlanTripImpl> get copyWith =>
      __$$PlanTripImplCopyWithImpl<_$PlanTripImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanTripImplToJson(this);
  }
}

abstract class _PlanTrip implements PlanTrip {
  const factory _PlanTrip({
    @JsonKey(name: 'break_start') required final DateTime breakStart,
    @JsonKey(name: 'break_end') required final DateTime breakEnd,
    @JsonKey(name: 'break_length') required final int breakLength,
    @JsonKey(name: 'pto_dates') required final List<DateTime> ptoDates,
    @JsonKey(name: 'pto_cost') required final int ptoCost,
    required final List<String> anchors,
  }) = _$PlanTripImpl;

  factory _PlanTrip.fromJson(Map<String, dynamic> json) =
      _$PlanTripImpl.fromJson;

  @override
  @JsonKey(name: 'break_start')
  DateTime get breakStart;
  @override
  @JsonKey(name: 'break_end')
  DateTime get breakEnd;
  @override
  @JsonKey(name: 'break_length')
  int get breakLength;
  @override
  @JsonKey(name: 'pto_dates')
  List<DateTime> get ptoDates;
  @override
  @JsonKey(name: 'pto_cost')
  int get ptoCost;
  @override
  List<String> get anchors;

  /// Create a copy of PlanTrip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanTripImplCopyWith<_$PlanTripImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
