// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 1;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      habitName: fields[1] as String,
      habitDescription: fields[2] as String?,
      emoji: fields[3] as String?,
      reminderModel: fields[4] as ReminderModel?,
      dailyTarget: fields[5] as int,
      colorCode: fields[6] as int,
      completions: fields[7] == null ? {} : (fields[7] as Map).cast<String, CompletionEntry>(),
      archiveDate: fields[8] as DateTime?,
      status: fields[10] as HabitStatus,
      categoryIds: fields[11] == null ? [] : (fields[11] as List).cast<String>(),
      difficulty: fields[12] as HabitDifficulty,
      rewardFactor: fields[13] as double,
      completionTime: fields[14] as DateTime?,
      syncStatus: fields[15] as SyncStatus,
      updatedAt: fields[16] as DateTime?,
      constellationPosX: fields[17] as double?,
      constellationPosY: fields[18] as double?,
      linkedHabitIds: fields[19] == null ? [] : (fields[19] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitName)
      ..writeByte(2)
      ..write(obj.habitDescription)
      ..writeByte(3)
      ..write(obj.emoji)
      ..writeByte(4)
      ..write(obj.reminderModel)
      ..writeByte(5)
      ..write(obj.dailyTarget)
      ..writeByte(6)
      ..write(obj.colorCode)
      ..writeByte(7)
      ..write(obj.completions)
      ..writeByte(8)
      ..write(obj.archiveDate)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.categoryIds)
      ..writeByte(12)
      ..write(obj.difficulty)
      ..writeByte(13)
      ..write(obj.rewardFactor)
      ..writeByte(14)
      ..write(obj.completionTime)
      ..writeByte(15)
      ..write(obj.syncStatus)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.constellationPosX)
      ..writeByte(18)
      ..write(obj.constellationPosY)
      ..writeByte(19)
      ..write(obj.linkedHabitIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is HabitAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitImpl _$$HabitImplFromJson(Map<String, dynamic> json) => _$HabitImpl(
      id: json['id'] as String,
      habitName: json['habitName'] as String,
      habitDescription: json['habitDescription'] as String?,
      emoji: json['emoji'] as String?,
      reminderModel: json['reminderModel'] == null ? null : ReminderModel.fromJson(json['reminderModel'] as Map<String, dynamic>),
      dailyTarget: (json['dailyTarget'] as num?)?.toInt() ?? 1,
      colorCode: (json['colorCode'] as num).toInt(),
      completions: (json['completions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, CompletionEntry.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      archiveDate: const TimestampConverter().fromJson(json['archiveDate']),
      status: $enumDecodeNullable(_$HabitStatusEnumMap, json['status']) ?? HabitStatus.active,
      categoryIds: (json['categoryIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      difficulty: $enumDecodeNullable(_$HabitDifficultyEnumMap, json['difficulty']) ?? HabitDifficulty.moderate,
      rewardFactor: (json['rewardFactor'] as num?)?.toDouble() ?? 1.0,
      completionTime: const TimestampConverter().fromJson(json['completionTime']),
      syncStatus: $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ?? SyncStatus.synced,
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      constellationPosX: (json['constellationPosX'] as num?)?.toDouble(),
      constellationPosY: (json['constellationPosY'] as num?)?.toDouble(),
      linkedHabitIds: (json['linkedHabitIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );

Map<String, dynamic> _$$HabitImplToJson(_$HabitImpl instance) => <String, dynamic>{
      'id': instance.id,
      'habitName': instance.habitName,
      'habitDescription': instance.habitDescription,
      'emoji': instance.emoji,
      'reminderModel': instance.reminderModel,
      'dailyTarget': instance.dailyTarget,
      'colorCode': instance.colorCode,
      'completions': instance.completions,
      'archiveDate': const TimestampConverter().toJson(instance.archiveDate),
      'status': _$HabitStatusEnumMap[instance.status]!,
      'categoryIds': instance.categoryIds,
      'difficulty': _$HabitDifficultyEnumMap[instance.difficulty]!,
      'rewardFactor': instance.rewardFactor,
      'completionTime': const TimestampConverter().toJson(instance.completionTime),
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'constellationPosX': instance.constellationPosX,
      'constellationPosY': instance.constellationPosY,
      'linkedHabitIds': instance.linkedHabitIds,
    };

const _$HabitStatusEnumMap = {
  HabitStatus.active: 'active',
  HabitStatus.archived: 'archived',
};

const _$HabitDifficultyEnumMap = {
  HabitDifficulty.veryEasy: 'veryEasy',
  HabitDifficulty.easy: 'easy',
  HabitDifficulty.moderate: 'moderate',
  HabitDifficulty.difficult: 'difficult',
  HabitDifficulty.veryDifficult: 'veryDifficult',
};

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
  SyncStatus.deleted: 'deleted',
};
