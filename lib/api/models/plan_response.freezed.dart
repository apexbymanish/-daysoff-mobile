// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlanResponse _$PlanResponseFromJson(Map<String, dynamic> json) {
  return _PlanResponse.fromJson(json);
}

/// @nodoc
mixin _$PlanResponse {
  String get country => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  int get budget => throw _privateConstructorUsedError;
  List<String> get workweek => throw _privateConstructorUsedError;
  @JsonKey(name: 'workweek_source')
  String get workweekSource => throw _privateConstructorUsedError;
  @JsonKey(name: 'results_by_length')
  Map<String, List<PlanTrip>> get resultsByLength =>
      throw _privateConstructorUsedError;

  /// Serializes this PlanResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanResponseCopyWith<PlanResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanResponseCopyWith<$Res> {
  factory $PlanResponseCopyWith(
    PlanResponse value,
    $Res Function(PlanResponse) then,
  ) = _$PlanResponseCopyWithImpl<$Res, PlanResponse>;
  @useResult
  $Res call({
    String country,
    int year,
    int budget,
    List<String> workweek,
    @JsonKey(name: 'workweek_source') String workweekSource,
    @JsonKey(name: 'results_by_length')
    Map<String, List<PlanTrip>> resultsByLength,
  });
}

/// @nodoc
class _$PlanResponseCopyWithImpl<$Res, $Val extends PlanResponse>
    implements $PlanResponseCopyWith<$Res> {
  _$PlanResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? country = null,
    Object? year = null,
    Object? budget = null,
    Object? workweek = null,
    Object? workweekSource = null,
    Object? resultsByLength = null,
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
            budget: null == budget
                ? _value.budget
                : budget // ignore: cast_nullable_to_non_nullable
                      as int,
            workweek: null == workweek
                ? _value.workweek
                : workweek // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            workweekSource: null == workweekSource
                ? _value.workweekSource
                : workweekSource // ignore: cast_nullable_to_non_nullable
                      as String,
            resultsByLength: null == resultsByLength
                ? _value.resultsByLength
                : resultsByLength // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<PlanTrip>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlanResponseImplCopyWith<$Res>
    implements $PlanResponseCopyWith<$Res> {
  factory _$$PlanResponseImplCopyWith(
    _$PlanResponseImpl value,
    $Res Function(_$PlanResponseImpl) then,
  ) = __$$PlanResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String country,
    int year,
    int budget,
    List<String> workweek,
    @JsonKey(name: 'workweek_source') String workweekSource,
    @JsonKey(name: 'results_by_length')
    Map<String, List<PlanTrip>> resultsByLength,
  });
}

/// @nodoc
class __$$PlanResponseImplCopyWithImpl<$Res>
    extends _$PlanResponseCopyWithImpl<$Res, _$PlanResponseImpl>
    implements _$$PlanResponseImplCopyWith<$Res> {
  __$$PlanResponseImplCopyWithImpl(
    _$PlanResponseImpl _value,
    $Res Function(_$PlanResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlanResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? country = null,
    Object? year = null,
    Object? budget = null,
    Object? workweek = null,
    Object? workweekSource = null,
    Object? resultsByLength = null,
  }) {
    return _then(
      _$PlanResponseImpl(
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        budget: null == budget
            ? _value.budget
            : budget // ignore: cast_nullable_to_non_nullable
                  as int,
        workweek: null == workweek
            ? _value._workweek
            : workweek // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        workweekSource: null == workweekSource
            ? _value.workweekSource
            : workweekSource // ignore: cast_nullable_to_non_nullable
                  as String,
        resultsByLength: null == resultsByLength
            ? _value._resultsByLength
            : resultsByLength // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<PlanTrip>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanResponseImpl implements _PlanResponse {
  const _$PlanResponseImpl({
    required this.country,
    required this.year,
    required this.budget,
    required final List<String> workweek,
    @JsonKey(name: 'workweek_source') required this.workweekSource,
    @JsonKey(name: 'results_by_length')
    required final Map<String, List<PlanTrip>> resultsByLength,
  }) : _workweek = workweek,
       _resultsByLength = resultsByLength;

  factory _$PlanResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanResponseImplFromJson(json);

  @override
  final String country;
  @override
  final int year;
  @override
  final int budget;
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
  final Map<String, List<PlanTrip>> _resultsByLength;
  @override
  @JsonKey(name: 'results_by_length')
  Map<String, List<PlanTrip>> get resultsByLength {
    if (_resultsByLength is EqualUnmodifiableMapView) return _resultsByLength;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_resultsByLength);
  }

  @override
  String toString() {
    return 'PlanResponse(country: $country, year: $year, budget: $budget, workweek: $workweek, workweekSource: $workweekSource, resultsByLength: $resultsByLength)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanResponseImpl &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            const DeepCollectionEquality().equals(other._workweek, _workweek) &&
            (identical(other.workweekSource, workweekSource) ||
                other.workweekSource == workweekSource) &&
            const DeepCollectionEquality().equals(
              other._resultsByLength,
              _resultsByLength,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    country,
    year,
    budget,
    const DeepCollectionEquality().hash(_workweek),
    workweekSource,
    const DeepCollectionEquality().hash(_resultsByLength),
  );

  /// Create a copy of PlanResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanResponseImplCopyWith<_$PlanResponseImpl> get copyWith =>
      __$$PlanResponseImplCopyWithImpl<_$PlanResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanResponseImplToJson(this);
  }
}

abstract class _PlanResponse implements PlanResponse {
  const factory _PlanResponse({
    required final String country,
    required final int year,
    required final int budget,
    required final List<String> workweek,
    @JsonKey(name: 'workweek_source') required final String workweekSource,
    @JsonKey(name: 'results_by_length')
    required final Map<String, List<PlanTrip>> resultsByLength,
  }) = _$PlanResponseImpl;

  factory _PlanResponse.fromJson(Map<String, dynamic> json) =
      _$PlanResponseImpl.fromJson;

  @override
  String get country;
  @override
  int get year;
  @override
  int get budget;
  @override
  List<String> get workweek;
  @override
  @JsonKey(name: 'workweek_source')
  String get workweekSource;
  @override
  @JsonKey(name: 'results_by_length')
  Map<String, List<PlanTrip>> get resultsByLength;

  /// Create a copy of PlanResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanResponseImplCopyWith<_$PlanResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
