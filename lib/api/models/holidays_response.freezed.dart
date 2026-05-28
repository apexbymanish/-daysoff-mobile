// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'holidays_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HolidaysResponse _$HolidaysResponseFromJson(Map<String, dynamic> json) {
  return _HolidaysResponse.fromJson(json);
}

/// @nodoc
mixin _$HolidaysResponse {
  String get country => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  List<Holiday> get holidays => throw _privateConstructorUsedError;

  /// Serializes this HolidaysResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HolidaysResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HolidaysResponseCopyWith<HolidaysResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HolidaysResponseCopyWith<$Res> {
  factory $HolidaysResponseCopyWith(
    HolidaysResponse value,
    $Res Function(HolidaysResponse) then,
  ) = _$HolidaysResponseCopyWithImpl<$Res, HolidaysResponse>;
  @useResult
  $Res call({String country, int year, int count, List<Holiday> holidays});
}

/// @nodoc
class _$HolidaysResponseCopyWithImpl<$Res, $Val extends HolidaysResponse>
    implements $HolidaysResponseCopyWith<$Res> {
  _$HolidaysResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HolidaysResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? country = null,
    Object? year = null,
    Object? count = null,
    Object? holidays = null,
  }) {
    return _then(
      _value.copyWith(
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            holidays: null == holidays
                ? _value.holidays
                : holidays // ignore: cast_nullable_to_non_nullable
                      as List<Holiday>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HolidaysResponseImplCopyWith<$Res>
    implements $HolidaysResponseCopyWith<$Res> {
  factory _$$HolidaysResponseImplCopyWith(
    _$HolidaysResponseImpl value,
    $Res Function(_$HolidaysResponseImpl) then,
  ) = __$$HolidaysResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String country, int year, int count, List<Holiday> holidays});
}

/// @nodoc
class __$$HolidaysResponseImplCopyWithImpl<$Res>
    extends _$HolidaysResponseCopyWithImpl<$Res, _$HolidaysResponseImpl>
    implements _$$HolidaysResponseImplCopyWith<$Res> {
  __$$HolidaysResponseImplCopyWithImpl(
    _$HolidaysResponseImpl _value,
    $Res Function(_$HolidaysResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HolidaysResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? country = null,
    Object? year = null,
    Object? count = null,
    Object? holidays = null,
  }) {
    return _then(
      _$HolidaysResponseImpl(
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        holidays: null == holidays
            ? _value._holidays
            : holidays // ignore: cast_nullable_to_non_nullable
                  as List<Holiday>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HolidaysResponseImpl implements _HolidaysResponse {
  const _$HolidaysResponseImpl({
    required this.country,
    required this.year,
    required this.count,
    required final List<Holiday> holidays,
  }) : _holidays = holidays;

  factory _$HolidaysResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$HolidaysResponseImplFromJson(json);

  @override
  final String country;
  @override
  final int year;
  @override
  final int count;
  final List<Holiday> _holidays;
  @override
  List<Holiday> get holidays {
    if (_holidays is EqualUnmodifiableListView) return _holidays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_holidays);
  }

  @override
  String toString() {
    return 'HolidaysResponse(country: $country, year: $year, count: $count, holidays: $holidays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HolidaysResponseImpl &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(other._holidays, _holidays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    country,
    year,
    count,
    const DeepCollectionEquality().hash(_holidays),
  );

  /// Create a copy of HolidaysResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HolidaysResponseImplCopyWith<_$HolidaysResponseImpl> get copyWith =>
      __$$HolidaysResponseImplCopyWithImpl<_$HolidaysResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HolidaysResponseImplToJson(this);
  }
}

abstract class _HolidaysResponse implements HolidaysResponse {
  const factory _HolidaysResponse({
    required final String country,
    required final int year,
    required final int count,
    required final List<Holiday> holidays,
  }) = _$HolidaysResponseImpl;

  factory _HolidaysResponse.fromJson(Map<String, dynamic> json) =
      _$HolidaysResponseImpl.fromJson;

  @override
  String get country;
  @override
  int get year;
  @override
  int get count;
  @override
  List<Holiday> get holidays;

  /// Create a copy of HolidaysResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HolidaysResponseImplCopyWith<_$HolidaysResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
