// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sandwich_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SandwichRecord _$SandwichRecordFromJson(Map<String, dynamic> json) {
  return _SandwichRecord.fromJson(json);
}

/// @nodoc
mixin _$SandwichRecord {
  @JsonKey(name: 'pto_date')
  DateTime get ptoDate => throw _privateConstructorUsedError;
  String get weekday => throw _privateConstructorUsedError;
  @JsonKey(name: 'break_start')
  DateTime get breakStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'break_end')
  DateTime get breakEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'break_length')
  int get breakLength => throw _privateConstructorUsedError;
  @JsonKey(name: 'pto_cost')
  int get ptoCost => throw _privateConstructorUsedError;
  String get context => throw _privateConstructorUsedError;

  /// Serializes this SandwichRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SandwichRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SandwichRecordCopyWith<SandwichRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SandwichRecordCopyWith<$Res> {
  factory $SandwichRecordCopyWith(
    SandwichRecord value,
    $Res Function(SandwichRecord) then,
  ) = _$SandwichRecordCopyWithImpl<$Res, SandwichRecord>;
  @useResult
  $Res call({
    @JsonKey(name: 'pto_date') DateTime ptoDate,
    String weekday,
    @JsonKey(name: 'break_start') DateTime breakStart,
    @JsonKey(name: 'break_end') DateTime breakEnd,
    @JsonKey(name: 'break_length') int breakLength,
    @JsonKey(name: 'pto_cost') int ptoCost,
    String context,
  });
}

/// @nodoc
class _$SandwichRecordCopyWithImpl<$Res, $Val extends SandwichRecord>
    implements $SandwichRecordCopyWith<$Res> {
  _$SandwichRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SandwichRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ptoDate = null,
    Object? weekday = null,
    Object? breakStart = null,
    Object? breakEnd = null,
    Object? breakLength = null,
    Object? ptoCost = null,
    Object? context = null,
  }) {
    return _then(
      _value.copyWith(
            ptoDate: null == ptoDate
                ? _value.ptoDate
                : ptoDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            weekday: null == weekday
                ? _value.weekday
                : weekday // ignore: cast_nullable_to_non_nullable
                      as String,
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
            ptoCost: null == ptoCost
                ? _value.ptoCost
                : ptoCost // ignore: cast_nullable_to_non_nullable
                      as int,
            context: null == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SandwichRecordImplCopyWith<$Res>
    implements $SandwichRecordCopyWith<$Res> {
  factory _$$SandwichRecordImplCopyWith(
    _$SandwichRecordImpl value,
    $Res Function(_$SandwichRecordImpl) then,
  ) = __$$SandwichRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'pto_date') DateTime ptoDate,
    String weekday,
    @JsonKey(name: 'break_start') DateTime breakStart,
    @JsonKey(name: 'break_end') DateTime breakEnd,
    @JsonKey(name: 'break_length') int breakLength,
    @JsonKey(name: 'pto_cost') int ptoCost,
    String context,
  });
}

/// @nodoc
class __$$SandwichRecordImplCopyWithImpl<$Res>
    extends _$SandwichRecordCopyWithImpl<$Res, _$SandwichRecordImpl>
    implements _$$SandwichRecordImplCopyWith<$Res> {
  __$$SandwichRecordImplCopyWithImpl(
    _$SandwichRecordImpl _value,
    $Res Function(_$SandwichRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SandwichRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ptoDate = null,
    Object? weekday = null,
    Object? breakStart = null,
    Object? breakEnd = null,
    Object? breakLength = null,
    Object? ptoCost = null,
    Object? context = null,
  }) {
    return _then(
      _$SandwichRecordImpl(
        ptoDate: null == ptoDate
            ? _value.ptoDate
            : ptoDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        weekday: null == weekday
            ? _value.weekday
            : weekday // ignore: cast_nullable_to_non_nullable
                  as String,
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
        ptoCost: null == ptoCost
            ? _value.ptoCost
            : ptoCost // ignore: cast_nullable_to_non_nullable
                  as int,
        context: null == context
            ? _value.context
            : context // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SandwichRecordImpl implements _SandwichRecord {
  const _$SandwichRecordImpl({
    @JsonKey(name: 'pto_date') required this.ptoDate,
    required this.weekday,
    @JsonKey(name: 'break_start') required this.breakStart,
    @JsonKey(name: 'break_end') required this.breakEnd,
    @JsonKey(name: 'break_length') required this.breakLength,
    @JsonKey(name: 'pto_cost') required this.ptoCost,
    required this.context,
  });

  factory _$SandwichRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$SandwichRecordImplFromJson(json);

  @override
  @JsonKey(name: 'pto_date')
  final DateTime ptoDate;
  @override
  final String weekday;
  @override
  @JsonKey(name: 'break_start')
  final DateTime breakStart;
  @override
  @JsonKey(name: 'break_end')
  final DateTime breakEnd;
  @override
  @JsonKey(name: 'break_length')
  final int breakLength;
  @override
  @JsonKey(name: 'pto_cost')
  final int ptoCost;
  @override
  final String context;

  @override
  String toString() {
    return 'SandwichRecord(ptoDate: $ptoDate, weekday: $weekday, breakStart: $breakStart, breakEnd: $breakEnd, breakLength: $breakLength, ptoCost: $ptoCost, context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SandwichRecordImpl &&
            (identical(other.ptoDate, ptoDate) || other.ptoDate == ptoDate) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.breakStart, breakStart) ||
                other.breakStart == breakStart) &&
            (identical(other.breakEnd, breakEnd) ||
                other.breakEnd == breakEnd) &&
            (identical(other.breakLength, breakLength) ||
                other.breakLength == breakLength) &&
            (identical(other.ptoCost, ptoCost) || other.ptoCost == ptoCost) &&
            (identical(other.context, context) || other.context == context));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    ptoDate,
    weekday,
    breakStart,
    breakEnd,
    breakLength,
    ptoCost,
    context,
  );

  /// Create a copy of SandwichRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SandwichRecordImplCopyWith<_$SandwichRecordImpl> get copyWith =>
      __$$SandwichRecordImplCopyWithImpl<_$SandwichRecordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SandwichRecordImplToJson(this);
  }
}

abstract class _SandwichRecord implements SandwichRecord {
  const factory _SandwichRecord({
    @JsonKey(name: 'pto_date') required final DateTime ptoDate,
    required final String weekday,
    @JsonKey(name: 'break_start') required final DateTime breakStart,
    @JsonKey(name: 'break_end') required final DateTime breakEnd,
    @JsonKey(name: 'break_length') required final int breakLength,
    @JsonKey(name: 'pto_cost') required final int ptoCost,
    required final String context,
  }) = _$SandwichRecordImpl;

  factory _SandwichRecord.fromJson(Map<String, dynamic> json) =
      _$SandwichRecordImpl.fromJson;

  @override
  @JsonKey(name: 'pto_date')
  DateTime get ptoDate;
  @override
  String get weekday;
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
  @JsonKey(name: 'pto_cost')
  int get ptoCost;
  @override
  String get context;

  /// Create a copy of SandwichRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SandwichRecordImplCopyWith<_$SandwichRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
