// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_break.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SavedBreak _$SavedBreakFromJson(Map<String, dynamic> json) {
  return _SavedBreak.fromJson(json);
}

/// @nodoc
mixin _$SavedBreak {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  DateTime get start => throw _privateConstructorUsedError;
  DateTime get end => throw _privateConstructorUsedError;
  int get ptoCost => throw _privateConstructorUsedError;
  String get kind => throw _privateConstructorUsedError; // 'break' | 'sandwich'
  // Sync metadata (null for purely-local, never-synced breaks).
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Serializes this SavedBreak to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavedBreak
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavedBreakCopyWith<SavedBreak> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavedBreakCopyWith<$Res> {
  factory $SavedBreakCopyWith(
    SavedBreak value,
    $Res Function(SavedBreak) then,
  ) = _$SavedBreakCopyWithImpl<$Res, SavedBreak>;
  @useResult
  $Res call({
    String id,
    String label,
    DateTime start,
    DateTime end,
    int ptoCost,
    String kind,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$SavedBreakCopyWithImpl<$Res, $Val extends SavedBreak>
    implements $SavedBreakCopyWith<$Res> {
  _$SavedBreakCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavedBreak
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? start = null,
    Object? end = null,
    Object? ptoCost = null,
    Object? kind = null,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            start: null == start
                ? _value.start
                : start // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            end: null == end
                ? _value.end
                : end // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ptoCost: null == ptoCost
                ? _value.ptoCost
                : ptoCost // ignore: cast_nullable_to_non_nullable
                      as int,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SavedBreakImplCopyWith<$Res>
    implements $SavedBreakCopyWith<$Res> {
  factory _$$SavedBreakImplCopyWith(
    _$SavedBreakImpl value,
    $Res Function(_$SavedBreakImpl) then,
  ) = __$$SavedBreakImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String label,
    DateTime start,
    DateTime end,
    int ptoCost,
    String kind,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$SavedBreakImplCopyWithImpl<$Res>
    extends _$SavedBreakCopyWithImpl<$Res, _$SavedBreakImpl>
    implements _$$SavedBreakImplCopyWith<$Res> {
  __$$SavedBreakImplCopyWithImpl(
    _$SavedBreakImpl _value,
    $Res Function(_$SavedBreakImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SavedBreak
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? start = null,
    Object? end = null,
    Object? ptoCost = null,
    Object? kind = null,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$SavedBreakImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        start: null == start
            ? _value.start
            : start // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        end: null == end
            ? _value.end
            : end // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ptoCost: null == ptoCost
            ? _value.ptoCost
            : ptoCost // ignore: cast_nullable_to_non_nullable
                  as int,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SavedBreakImpl implements _SavedBreak {
  const _$SavedBreakImpl({
    required this.id,
    required this.label,
    required this.start,
    required this.end,
    required this.ptoCost,
    required this.kind,
    this.updatedAt,
    this.deletedAt,
  });

  factory _$SavedBreakImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavedBreakImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final DateTime start;
  @override
  final DateTime end;
  @override
  final int ptoCost;
  @override
  final String kind;
  // 'break' | 'sandwich'
  // Sync metadata (null for purely-local, never-synced breaks).
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'SavedBreak(id: $id, label: $label, start: $start, end: $end, ptoCost: $ptoCost, kind: $kind, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedBreakImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.ptoCost, ptoCost) || other.ptoCost == ptoCost) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    label,
    start,
    end,
    ptoCost,
    kind,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of SavedBreak
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedBreakImplCopyWith<_$SavedBreakImpl> get copyWith =>
      __$$SavedBreakImplCopyWithImpl<_$SavedBreakImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavedBreakImplToJson(this);
  }
}

abstract class _SavedBreak implements SavedBreak {
  const factory _SavedBreak({
    required final String id,
    required final String label,
    required final DateTime start,
    required final DateTime end,
    required final int ptoCost,
    required final String kind,
    final DateTime? updatedAt,
    final DateTime? deletedAt,
  }) = _$SavedBreakImpl;

  factory _SavedBreak.fromJson(Map<String, dynamic> json) =
      _$SavedBreakImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  DateTime get start;
  @override
  DateTime get end;
  @override
  int get ptoCost;
  @override
  String get kind; // 'break' | 'sandwich'
  // Sync metadata (null for purely-local, never-synced breaks).
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of SavedBreak
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavedBreakImplCopyWith<_$SavedBreakImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
