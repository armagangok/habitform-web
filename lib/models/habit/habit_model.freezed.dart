// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Habit _$HabitFromJson(Map<String, dynamic> json) {
  return _Habit.fromJson(json);
}

/// @nodoc
mixin _$Habit {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get habitName => throw _privateConstructorUsedError;
  @HiveField(2)
  String? get habitDescription => throw _privateConstructorUsedError;
  @HiveField(3)
  String? get emoji => throw _privateConstructorUsedError;
  @HiveField(4)
  ReminderModel? get reminderModel => throw _privateConstructorUsedError;
  @HiveField(5)
  int get dailyTarget => throw _privateConstructorUsedError;
  @HiveField(6)
  int get colorCode => throw _privateConstructorUsedError;
  @HiveField(7, defaultValue: {})
  Map<String, CompletionEntry> get completions =>
      throw _privateConstructorUsedError;
  @TimestampConverter()
  @HiveField(8)
  DateTime? get archiveDate => throw _privateConstructorUsedError;
  @HiveField(10)
  HabitStatus get status => throw _privateConstructorUsedError;
  @HiveField(11, defaultValue: [])
  List<String> get categoryIds => throw _privateConstructorUsedError;
  @HiveField(12)
  HabitDifficulty get difficulty => throw _privateConstructorUsedError;
  @HiveField(13, defaultValue: 1.0)
  double get rewardFactor => throw _privateConstructorUsedError;
  @TimestampConverter()
  @HiveField(14)
  DateTime? get completionTime => throw _privateConstructorUsedError;
  @HiveField(15)
  SyncStatus get syncStatus => throw _privateConstructorUsedError;
  @TimestampConverter()
  @HiveField(16)
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @HiveField(17)
  double? get constellationPosX => throw _privateConstructorUsedError;
  @HiveField(18)
  double? get constellationPosY => throw _privateConstructorUsedError;
  @HiveField(19, defaultValue: [])
  List<String> get linkedHabitIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HabitCopyWith<Habit> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitCopyWith<$Res> {
  factory $HabitCopyWith(Habit value, $Res Function(Habit) then) =
      _$HabitCopyWithImpl<$Res, Habit>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String habitName,
      @HiveField(2) String? habitDescription,
      @HiveField(3) String? emoji,
      @HiveField(4) ReminderModel? reminderModel,
      @HiveField(5) int dailyTarget,
      @HiveField(6) int colorCode,
      @HiveField(7, defaultValue: {}) Map<String, CompletionEntry> completions,
      @TimestampConverter() @HiveField(8) DateTime? archiveDate,
      @HiveField(10) HabitStatus status,
      @HiveField(11, defaultValue: []) List<String> categoryIds,
      @HiveField(12) HabitDifficulty difficulty,
      @HiveField(13, defaultValue: 1.0) double rewardFactor,
      @TimestampConverter() @HiveField(14) DateTime? completionTime,
      @HiveField(15) SyncStatus syncStatus,
      @TimestampConverter() @HiveField(16) DateTime? updatedAt,
      @HiveField(17) double? constellationPosX,
      @HiveField(18) double? constellationPosY,
      @HiveField(19, defaultValue: []) List<String> linkedHabitIds});
}

/// @nodoc
class _$HabitCopyWithImpl<$Res, $Val extends Habit>
    implements $HabitCopyWith<$Res> {
  _$HabitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? habitName = null,
    Object? habitDescription = freezed,
    Object? emoji = freezed,
    Object? reminderModel = freezed,
    Object? dailyTarget = null,
    Object? colorCode = null,
    Object? completions = null,
    Object? archiveDate = freezed,
    Object? status = null,
    Object? categoryIds = null,
    Object? difficulty = null,
    Object? rewardFactor = null,
    Object? completionTime = freezed,
    Object? syncStatus = null,
    Object? updatedAt = freezed,
    Object? constellationPosX = freezed,
    Object? constellationPosY = freezed,
    Object? linkedHabitIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      habitName: null == habitName
          ? _value.habitName
          : habitName // ignore: cast_nullable_to_non_nullable
              as String,
      habitDescription: freezed == habitDescription
          ? _value.habitDescription
          : habitDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      emoji: freezed == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String?,
      reminderModel: freezed == reminderModel
          ? _value.reminderModel
          : reminderModel // ignore: cast_nullable_to_non_nullable
              as ReminderModel?,
      dailyTarget: null == dailyTarget
          ? _value.dailyTarget
          : dailyTarget // ignore: cast_nullable_to_non_nullable
              as int,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as int,
      completions: null == completions
          ? _value.completions
          : completions // ignore: cast_nullable_to_non_nullable
              as Map<String, CompletionEntry>,
      archiveDate: freezed == archiveDate
          ? _value.archiveDate
          : archiveDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as HabitStatus,
      categoryIds: null == categoryIds
          ? _value.categoryIds
          : categoryIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as HabitDifficulty,
      rewardFactor: null == rewardFactor
          ? _value.rewardFactor
          : rewardFactor // ignore: cast_nullable_to_non_nullable
              as double,
      completionTime: freezed == completionTime
          ? _value.completionTime
          : completionTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      constellationPosX: freezed == constellationPosX
          ? _value.constellationPosX
          : constellationPosX // ignore: cast_nullable_to_non_nullable
              as double?,
      constellationPosY: freezed == constellationPosY
          ? _value.constellationPosY
          : constellationPosY // ignore: cast_nullable_to_non_nullable
              as double?,
      linkedHabitIds: null == linkedHabitIds
          ? _value.linkedHabitIds
          : linkedHabitIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HabitImplCopyWith<$Res> implements $HabitCopyWith<$Res> {
  factory _$$HabitImplCopyWith(
          _$HabitImpl value, $Res Function(_$HabitImpl) then) =
      __$$HabitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String habitName,
      @HiveField(2) String? habitDescription,
      @HiveField(3) String? emoji,
      @HiveField(4) ReminderModel? reminderModel,
      @HiveField(5) int dailyTarget,
      @HiveField(6) int colorCode,
      @HiveField(7, defaultValue: {}) Map<String, CompletionEntry> completions,
      @TimestampConverter() @HiveField(8) DateTime? archiveDate,
      @HiveField(10) HabitStatus status,
      @HiveField(11, defaultValue: []) List<String> categoryIds,
      @HiveField(12) HabitDifficulty difficulty,
      @HiveField(13, defaultValue: 1.0) double rewardFactor,
      @TimestampConverter() @HiveField(14) DateTime? completionTime,
      @HiveField(15) SyncStatus syncStatus,
      @TimestampConverter() @HiveField(16) DateTime? updatedAt,
      @HiveField(17) double? constellationPosX,
      @HiveField(18) double? constellationPosY,
      @HiveField(19, defaultValue: []) List<String> linkedHabitIds});
}

/// @nodoc
class __$$HabitImplCopyWithImpl<$Res>
    extends _$HabitCopyWithImpl<$Res, _$HabitImpl>
    implements _$$HabitImplCopyWith<$Res> {
  __$$HabitImplCopyWithImpl(
      _$HabitImpl _value, $Res Function(_$HabitImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? habitName = null,
    Object? habitDescription = freezed,
    Object? emoji = freezed,
    Object? reminderModel = freezed,
    Object? dailyTarget = null,
    Object? colorCode = null,
    Object? completions = null,
    Object? archiveDate = freezed,
    Object? status = null,
    Object? categoryIds = null,
    Object? difficulty = null,
    Object? rewardFactor = null,
    Object? completionTime = freezed,
    Object? syncStatus = null,
    Object? updatedAt = freezed,
    Object? constellationPosX = freezed,
    Object? constellationPosY = freezed,
    Object? linkedHabitIds = null,
  }) {
    return _then(_$HabitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      habitName: null == habitName
          ? _value.habitName
          : habitName // ignore: cast_nullable_to_non_nullable
              as String,
      habitDescription: freezed == habitDescription
          ? _value.habitDescription
          : habitDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      emoji: freezed == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String?,
      reminderModel: freezed == reminderModel
          ? _value.reminderModel
          : reminderModel // ignore: cast_nullable_to_non_nullable
              as ReminderModel?,
      dailyTarget: null == dailyTarget
          ? _value.dailyTarget
          : dailyTarget // ignore: cast_nullable_to_non_nullable
              as int,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as int,
      completions: null == completions
          ? _value._completions
          : completions // ignore: cast_nullable_to_non_nullable
              as Map<String, CompletionEntry>,
      archiveDate: freezed == archiveDate
          ? _value.archiveDate
          : archiveDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as HabitStatus,
      categoryIds: null == categoryIds
          ? _value._categoryIds
          : categoryIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as HabitDifficulty,
      rewardFactor: null == rewardFactor
          ? _value.rewardFactor
          : rewardFactor // ignore: cast_nullable_to_non_nullable
              as double,
      completionTime: freezed == completionTime
          ? _value.completionTime
          : completionTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      constellationPosX: freezed == constellationPosX
          ? _value.constellationPosX
          : constellationPosX // ignore: cast_nullable_to_non_nullable
              as double?,
      constellationPosY: freezed == constellationPosY
          ? _value.constellationPosY
          : constellationPosY // ignore: cast_nullable_to_non_nullable
              as double?,
      linkedHabitIds: null == linkedHabitIds
          ? _value._linkedHabitIds
          : linkedHabitIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HabitImpl extends _Habit {
  _$HabitImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.habitName,
      @HiveField(2) this.habitDescription,
      @HiveField(3) this.emoji,
      @HiveField(4) this.reminderModel,
      @HiveField(5) this.dailyTarget = 1,
      @HiveField(6) required this.colorCode,
      @HiveField(7, defaultValue: {})
      final Map<String, CompletionEntry> completions = const {},
      @TimestampConverter() @HiveField(8) this.archiveDate,
      @HiveField(10) this.status = HabitStatus.active,
      @HiveField(11, defaultValue: [])
      final List<String> categoryIds = const [],
      @HiveField(12) this.difficulty = HabitDifficulty.moderate,
      @HiveField(13, defaultValue: 1.0) this.rewardFactor = 1.0,
      @TimestampConverter() @HiveField(14) this.completionTime,
      @HiveField(15) this.syncStatus = SyncStatus.synced,
      @TimestampConverter() @HiveField(16) this.updatedAt,
      @HiveField(17) this.constellationPosX,
      @HiveField(18) this.constellationPosY,
      @HiveField(19, defaultValue: [])
      final List<String> linkedHabitIds = const []})
      : _completions = completions,
        _categoryIds = categoryIds,
        _linkedHabitIds = linkedHabitIds,
        super._();

  factory _$HabitImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String habitName;
  @override
  @HiveField(2)
  final String? habitDescription;
  @override
  @HiveField(3)
  final String? emoji;
  @override
  @HiveField(4)
  final ReminderModel? reminderModel;
  @override
  @JsonKey()
  @HiveField(5)
  final int dailyTarget;
  @override
  @HiveField(6)
  final int colorCode;
  final Map<String, CompletionEntry> _completions;
  @override
  @JsonKey()
  @HiveField(7, defaultValue: {})
  Map<String, CompletionEntry> get completions {
    if (_completions is EqualUnmodifiableMapView) return _completions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_completions);
  }

  @override
  @TimestampConverter()
  @HiveField(8)
  final DateTime? archiveDate;
  @override
  @JsonKey()
  @HiveField(10)
  final HabitStatus status;
  final List<String> _categoryIds;
  @override
  @JsonKey()
  @HiveField(11, defaultValue: [])
  List<String> get categoryIds {
    if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categoryIds);
  }

  @override
  @JsonKey()
  @HiveField(12)
  final HabitDifficulty difficulty;
  @override
  @JsonKey()
  @HiveField(13, defaultValue: 1.0)
  final double rewardFactor;
  @override
  @TimestampConverter()
  @HiveField(14)
  final DateTime? completionTime;
  @override
  @JsonKey()
  @HiveField(15)
  final SyncStatus syncStatus;
  @override
  @TimestampConverter()
  @HiveField(16)
  final DateTime? updatedAt;
  @override
  @HiveField(17)
  final double? constellationPosX;
  @override
  @HiveField(18)
  final double? constellationPosY;
  final List<String> _linkedHabitIds;
  @override
  @JsonKey()
  @HiveField(19, defaultValue: [])
  List<String> get linkedHabitIds {
    if (_linkedHabitIds is EqualUnmodifiableListView) return _linkedHabitIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_linkedHabitIds);
  }

  @override
  String toString() {
    return 'Habit(id: $id, habitName: $habitName, habitDescription: $habitDescription, emoji: $emoji, reminderModel: $reminderModel, dailyTarget: $dailyTarget, colorCode: $colorCode, completions: $completions, archiveDate: $archiveDate, status: $status, categoryIds: $categoryIds, difficulty: $difficulty, rewardFactor: $rewardFactor, completionTime: $completionTime, syncStatus: $syncStatus, updatedAt: $updatedAt, constellationPosX: $constellationPosX, constellationPosY: $constellationPosY, linkedHabitIds: $linkedHabitIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.habitName, habitName) ||
                other.habitName == habitName) &&
            (identical(other.habitDescription, habitDescription) ||
                other.habitDescription == habitDescription) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.reminderModel, reminderModel) ||
                other.reminderModel == reminderModel) &&
            (identical(other.dailyTarget, dailyTarget) ||
                other.dailyTarget == dailyTarget) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            const DeepCollectionEquality()
                .equals(other._completions, _completions) &&
            (identical(other.archiveDate, archiveDate) ||
                other.archiveDate == archiveDate) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._categoryIds, _categoryIds) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.rewardFactor, rewardFactor) ||
                other.rewardFactor == rewardFactor) &&
            (identical(other.completionTime, completionTime) ||
                other.completionTime == completionTime) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.constellationPosX, constellationPosX) ||
                other.constellationPosX == constellationPosX) &&
            (identical(other.constellationPosY, constellationPosY) ||
                other.constellationPosY == constellationPosY) &&
            const DeepCollectionEquality()
                .equals(other._linkedHabitIds, _linkedHabitIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        habitName,
        habitDescription,
        emoji,
        reminderModel,
        dailyTarget,
        colorCode,
        const DeepCollectionEquality().hash(_completions),
        archiveDate,
        status,
        const DeepCollectionEquality().hash(_categoryIds),
        difficulty,
        rewardFactor,
        completionTime,
        syncStatus,
        updatedAt,
        constellationPosX,
        constellationPosY,
        const DeepCollectionEquality().hash(_linkedHabitIds)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitImplCopyWith<_$HabitImpl> get copyWith =>
      __$$HabitImplCopyWithImpl<_$HabitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitImplToJson(
      this,
    );
  }
}

abstract class _Habit extends Habit {
  factory _Habit(
          {@HiveField(0) required final String id,
          @HiveField(1) required final String habitName,
          @HiveField(2) final String? habitDescription,
          @HiveField(3) final String? emoji,
          @HiveField(4) final ReminderModel? reminderModel,
          @HiveField(5) final int dailyTarget,
          @HiveField(6) required final int colorCode,
          @HiveField(7, defaultValue: {})
          final Map<String, CompletionEntry> completions,
          @TimestampConverter() @HiveField(8) final DateTime? archiveDate,
          @HiveField(10) final HabitStatus status,
          @HiveField(11, defaultValue: []) final List<String> categoryIds,
          @HiveField(12) final HabitDifficulty difficulty,
          @HiveField(13, defaultValue: 1.0) final double rewardFactor,
          @TimestampConverter() @HiveField(14) final DateTime? completionTime,
          @HiveField(15) final SyncStatus syncStatus,
          @TimestampConverter() @HiveField(16) final DateTime? updatedAt,
          @HiveField(17) final double? constellationPosX,
          @HiveField(18) final double? constellationPosY,
          @HiveField(19, defaultValue: []) final List<String> linkedHabitIds}) =
      _$HabitImpl;
  _Habit._() : super._();

  factory _Habit.fromJson(Map<String, dynamic> json) = _$HabitImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get habitName;
  @override
  @HiveField(2)
  String? get habitDescription;
  @override
  @HiveField(3)
  String? get emoji;
  @override
  @HiveField(4)
  ReminderModel? get reminderModel;
  @override
  @HiveField(5)
  int get dailyTarget;
  @override
  @HiveField(6)
  int get colorCode;
  @override
  @HiveField(7, defaultValue: {})
  Map<String, CompletionEntry> get completions;
  @override
  @TimestampConverter()
  @HiveField(8)
  DateTime? get archiveDate;
  @override
  @HiveField(10)
  HabitStatus get status;
  @override
  @HiveField(11, defaultValue: [])
  List<String> get categoryIds;
  @override
  @HiveField(12)
  HabitDifficulty get difficulty;
  @override
  @HiveField(13, defaultValue: 1.0)
  double get rewardFactor;
  @override
  @TimestampConverter()
  @HiveField(14)
  DateTime? get completionTime;
  @override
  @HiveField(15)
  SyncStatus get syncStatus;
  @override
  @TimestampConverter()
  @HiveField(16)
  DateTime? get updatedAt;
  @override
  @HiveField(17)
  double? get constellationPosX;
  @override
  @HiveField(18)
  double? get constellationPosY;
  @override
  @HiveField(19, defaultValue: [])
  List<String> get linkedHabitIds;
  @override
  @JsonKey(ignore: true)
  _$$HabitImplCopyWith<_$HabitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
