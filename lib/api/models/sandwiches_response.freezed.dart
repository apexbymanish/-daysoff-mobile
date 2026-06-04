// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sandwiches_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SandwichesResponse _$SandwichesResponseFromJson(Map<String, dynamic> json) {
  return _SandwichesResponse.fromJson(json);
}

/// @nodoc
mixin _$SandwichesResponse {
  String get country => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  List<String> get workweek => throw _privateConstructorUsedError;
  @JsonKey(name: 'workweek_source')
  String get workweekSource => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  List<SandwichRecord> get sandwiches => throw _privateConstructorUsedError;

  /// Serializes this SandwichesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SandwichesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SandwichesResponseCopyWith<SandwichesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SandwichesResponseCopyWith<$Res> {
  factory $SandwichesResponseCopyWith(
    SandwichesResponse value,
    $Res Function(SandwichesResponse) then,
  ) = _$SandwichesResponseCopyWithImpl<$Res, SandwichesResponse>;
  @useResult
  $Res call({
    String country,
    int year,
    List<String> workweek,
    @JsonKey(name: 'workweek_source') String workweekSource,
    int count,
    List<SandwichRecord> sandwiches,
  });
}

/// @nodoc
class _$SandwichesResponseCopyWithImpl<$Res, $Val extends SandwichesResponse>
    implements $SandwichesResponseCopyWith<$Res> {
  _$SandwichesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SandwichesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? country = null,
    Object? year = null,
    Object? workweek = null,
    Object? workweekSource = null,
    Object? count = null,
    Object? sandwiches = null,
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
            workweek: null == workweek
                ? _value.workweek
                : workweek // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            workweekSource: null == workweekSource
                ? _value.workweekSource
                : workweekSource // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            sandwiches: null == sandwiches
                ? _value.sandwiches
                : sandwiches // ignore: cast_nullable_to_non_nullable
                      as List<SandwichRecord>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SandwichesResponseImplCopyWith<$Res>
    implements $SandwichesResponseCopyWith<$Res> {
  factory _$$SandwichesResponseImplCopyWith(
    _$SandwichesResponseImpl value,
    $Res Function(_$SandwichesResponseImpl) then,
  ) = __$$SandwichesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String country,
    int year,
    List<String> workweek,
    @JsonKey(name: 'workweek_source') String workweekSource,
    int count,
    List<SandwichRecord> sandwiches,
  });
}

/// @nodoc
class __$$SandwichesResponseImplCopyWithImpl<$Res>
    extends _$SandwichesResponseCopyWithImpl<$Res, _$SandwichesResponseImpl>
    implements _$$SandwichesResponseImplCopyWith<$Res> {
  __$$SandwichesResponseImplCopyWithImpl(
    _$SandwichesResponseImpl _value,
    $Res Function(_$SandwichesResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SandwichesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? country = null,
    Object? year = null,
    Object? workweek = null,
    Object? workweekSource = null,
    Object? count = null,
    Object? sandwiches = null,
  }) {
    return _then(
      _$SandwichesResponseImpl(
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        workweek: null == workweek
            ? _value._workweek
            : workweek // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        workweekSource: null == workweekSource
            ? _value.workweekSource
            : workweekSource // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        sandwiches: null == sandwiches
            ? _value._sandwiches
            : sandwiches // ignore: cast_nullable_to_non_nullable
                  as List<SandwichRecord>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SandwichesResponseImpl implements _SandwichesResponse {
  const _$SandwichesResponseImpl({
    required this.country,
    required this.year,
    required final List<String> workweek,
    @JsonKey(name: 'workweek_source') required this.workweekSource,
    required this.count,
    required final List<SandwichRecord> sandwiches,
  }) : _workweek = workweek,
       _sandwiches = sandwiches;

  factory _$SandwichesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SandwichesResponseImplFromJson(json);

  @override
  final String country;
  @override
  final int year;
  final List<String> _workweek;
  @override
  List<String> get workweek {
    if (_workweek is EqualUnmodifiableListView) return _workweek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workweek);
  }

  @override
  @JsonKey(name: 'workweek_source')
  final String workweekSource;
  @override
  final int count;
  final List<SandwichRecord> _sandwiches;
  @override
  List<SandwichRecord> get sandwiches {
    if (_sandwiches is EqualUnmodifiableListView) return _sandwiches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sandwiches);
  }

  @override
  String toString() {
    return 'SandwichesResponse(country: $country, year: $year, workweek: $workweek, workweekSource: $workweekSource, count: $count, sandwiches: $sandwiches)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SandwichesResponseImpl &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.year, year) || other.year == year) &&
            const DeepCollectionEquality().equals(other._workweek, _workweek) &&
            (identical(other.workweekSource, workweekSource) ||
                other.workweekSource == workweekSource) &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(
              other._sandwiches,
              _sandwiches,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    country,
    year,
    const DeepCollectionEquality().hash(_workweek),
    workweekSource,
    count,
    const DeepCollectionEquality().hash(_sandwiches),
  );

  /// Create a copy of SandwichesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SandwichesResponseImplCopyWith<_$SandwichesResponseImpl> get copyWith =>
      __$$SandwichesResponseImplCopyWithImpl<_$SandwichesResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SandwichesResponseImplToJson(this);
  }
}

abstract class _SandwichesResponse implements SandwichesResponse {
  const factory _SandwichesResponse({
    required final String country,
    required final int year,
    required final List<String> workweek,
    @JsonKey(name: 'workweek_source') required final String workweekSource,
    required final int count,
    required final List<SandwichRecord> sandwiches,
  }) = _$SandwichesResponseImpl;

  factory _SandwichesResponse.fromJson(Map<String, dynamic> json) =
      _$SandwichesResponseImpl.fromJson;

  @override
  String get country;
  @override
  int get year;
  @override
  List<String> get workweek;
  @override
  @JsonKey(name: 'workweek_source')
  String get workweekSource;
  @override
  int get count;
  @override
  List<SandwichRecord> get sandwiches;

  /// Create a copy of SandwichesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SandwichesResponseImplCopyWith<_$SandwichesResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
