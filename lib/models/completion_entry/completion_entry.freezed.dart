// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'completion_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CompletionEntry _$CompletionEntryFromJson(Map<String, dynamic> json) {
  return _CompletionEntry.fromJson(json);
}

/// @nodoc
mixin _$CompletionEntry {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  DateTime get date => throw _privateConstructorUsedError;
  @HiveField(2)
  bool get isCompleted => throw _privateConstructorUsedError;
  @HiveField(3)
  int get count => throw _privateConstructorUsedError;
  @HiveField(4)
  double? get rewardRating => throw _privateConstructorUsedError;
  @HiveField(5)
  SyncStatus get syncStatus => throw _privateConstructorUsedError;
  @HiveField(6)
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CompletionEntryCopyWith<CompletionEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompletionEntryCopyWith<$Res> {
  factory $CompletionEntryCopyWith(
          CompletionEntry value, $Res Function(CompletionEntry) then) =
      _$CompletionEntryCopyWithImpl<$Res, CompletionEntry>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) DateTime date,
      @HiveField(2) bool isCompleted,
      @HiveField(3) int count,
      @HiveField(4) double? rewardRating,
      @HiveField(5) SyncStatus syncStatus,
      @HiveField(6) DateTime? updatedAt});
}

/// @nodoc
class _$CompletionEntryCopyWithImpl<$Res, $Val extends CompletionEntry>
    implements $CompletionEntryCopyWith<$Res> {
  _$CompletionEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? isCompleted = null,
    Object? count = null,
    Object? rewardRating = freezed,
    Object? syncStatus = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      rewardRating: freezed == rewardRating
          ? _value.rewardRating
          : rewardRating // ignore: cast_nullable_to_non_nullable
              as double?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompletionEntryImplCopyWith<$Res>
    implements $CompletionEntryCopyWith<$Res> {
  factory _$$CompletionEntryImplCopyWith(_$CompletionEntryImpl value,
          $Res Function(_$CompletionEntryImpl) then) =
      __$$CompletionEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) DateTime date,
      @HiveField(2) bool isCompleted,
      @HiveField(3) int count,
      @HiveField(4) double? rewardRating,
      @HiveField(5) SyncStatus syncStatus,
      @HiveField(6) DateTime? updatedAt});
}

/// @nodoc
class __$$CompletionEntryImplCopyWithImpl<$Res>
    extends _$CompletionEntryCopyWithImpl<$Res, _$CompletionEntryImpl>
    implements _$$CompletionEntryImplCopyWith<$Res> {
  __$$CompletionEntryImplCopyWithImpl(
      _$CompletionEntryImpl _value, $Res Function(_$CompletionEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? isCompleted = null,
    Object? count = null,
    Object? rewardRating = freezed,
    Object? syncStatus = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$CompletionEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      rewardRating: freezed == rewardRating
          ? _value.rewardRating
          : rewardRating // ignore: cast_nullable_to_non_nullable
              as double?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompletionEntryImpl extends _CompletionEntry {
  _$CompletionEntryImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.date,
      @HiveField(2) required this.isCompleted,
      @HiveField(3) this.count = 1,
      @HiveField(4) this.rewardRating,
      @HiveField(5) this.syncStatus = SyncStatus.synced,
      @HiveField(6) this.updatedAt})
      : super._();

  factory _$CompletionEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompletionEntryImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final DateTime date;
  @override
  @HiveField(2)
  final bool isCompleted;
  @override
  @JsonKey()
  @HiveField(3)
  final int count;
  @override
  @HiveField(4)
  final double? rewardRating;
  @override
  @JsonKey()
  @HiveField(5)
  final SyncStatus syncStatus;
  @override
  @HiveField(6)
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'CompletionEntry(id: $id, date: $date, isCompleted: $isCompleted, count: $count, rewardRating: $rewardRating, syncStatus: $syncStatus, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompletionEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.rewardRating, rewardRating) ||
                other.rewardRating == rewardRating) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, date, isCompleted, count,
      rewardRating, syncStatus, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CompletionEntryImplCopyWith<_$CompletionEntryImpl> get copyWith =>
      __$$CompletionEntryImplCopyWithImpl<_$CompletionEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompletionEntryImplToJson(
      this,
    );
  }
}

abstract class _CompletionEntry extends CompletionEntry {
  factory _CompletionEntry(
      {@HiveField(0) required final String id,
      @HiveField(1) required final DateTime date,
      @HiveField(2) required final bool isCompleted,
      @HiveField(3) final int count,
      @HiveField(4) final double? rewardRating,
      @HiveField(5) final SyncStatus syncStatus,
      @HiveField(6) final DateTime? updatedAt}) = _$CompletionEntryImpl;
  _CompletionEntry._() : super._();

  factory _CompletionEntry.fromJson(Map<String, dynamic> json) =
      _$CompletionEntryImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  DateTime get date;
  @override
  @HiveField(2)
  bool get isCompleted;
  @override
  @HiveField(3)
  int get count;
  @override
  @HiveField(4)
  double? get rewardRating;
  @override
  @HiveField(5)
  SyncStatus get syncStatus;
  @override
  @HiveField(6)
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$CompletionEntryImplCopyWith<_$CompletionEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
