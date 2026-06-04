// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'countries_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CountriesResponse _$CountriesResponseFromJson(Map<String, dynamic> json) {
  return _CountriesResponse.fromJson(json);
}

/// @nodoc
mixin _$CountriesResponse {
  int get count => throw _privateConstructorUsedError;
  List<Country> get countries => throw _privateConstructorUsedError;

  /// Serializes this CountriesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CountriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CountriesResponseCopyWith<CountriesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CountriesResponseCopyWith<$Res> {
  factory $CountriesResponseCopyWith(
    CountriesResponse value,
    $Res Function(CountriesResponse) then,
  ) = _$CountriesResponseCopyWithImpl<$Res, CountriesResponse>;
  @useResult
  $Res call({int count, List<Country> countries});
}

/// @nodoc
class _$CountriesResponseCopyWithImpl<$Res, $Val extends CountriesResponse>
    implements $CountriesResponseCopyWith<$Res> {
  _$CountriesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CountriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? count = null, Object? countries = null}) {
    return _then(
      _value.copyWith(
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            countries: null == countries
                ? _value.countries
                : countries // ignore: cast_nullable_to_non_nullable
                      as List<Country>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CountriesResponseImplCopyWith<$Res>
    implements $CountriesResponseCopyWith<$Res> {
  factory _$$CountriesResponseImplCopyWith(
    _$CountriesResponseImpl value,
    $Res Function(_$CountriesResponseImpl) then,
  ) = __$$CountriesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int count, List<Country> countries});
}

/// @nodoc
class __$$CountriesResponseImplCopyWithImpl<$Res>
    extends _$CountriesResponseCopyWithImpl<$Res, _$CountriesResponseImpl>
    implements _$$CountriesResponseImplCopyWith<$Res> {
  __$$CountriesResponseImplCopyWithImpl(
    _$CountriesResponseImpl _value,
    $Res Function(_$CountriesResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CountriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? count = null, Object? countries = null}) {
    return _then(
      _$CountriesResponseImpl(
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        countries: null == countries
            ? _value._countries
            : countries // ignore: cast_nullable_to_non_nullable
                  as List<Country>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CountriesResponseImpl implements _CountriesResponse {
  const _$CountriesResponseImpl({
    required this.count,
    required final List<Country> countries,
  }) : _countries = countries;

  factory _$CountriesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CountriesResponseImplFromJson(json);

  @override
  final int count;
  final List<Country> _countries;
  @override
  List<Country> get countries {
    if (_countries is EqualUnmodifiableListView) return _countries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_countries);
  }

  @override
  String toString() {
    return 'CountriesResponse(count: $count, countries: $countries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CountriesResponseImpl &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(
              other._countries,
              _countries,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    count,
    const DeepCollectionEquality().hash(_countries),
  );

  /// Create a copy of CountriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CountriesResponseImplCopyWith<_$CountriesResponseImpl> get copyWith =>
      __$$CountriesResponseImplCopyWithImpl<_$CountriesResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CountriesResponseImplToJson(this);
  }
}

abstract class _CountriesResponse implements CountriesResponse {
  const factory _CountriesResponse({
    required final int count,
    required final List<Country> countries,
  }) = _$CountriesResponseImpl;

  factory _CountriesResponse.fromJson(Map<String, dynamic> json) =
      _$CountriesResponseImpl.fromJson;

  @override
  int get count;
  @override
  List<Country> get countries;

  /// Create a copy of CountriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CountriesResponseImplCopyWith<_$CountriesResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
