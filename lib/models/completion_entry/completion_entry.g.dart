// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompletionEntryAdapter extends TypeAdapter<CompletionEntry> {
  @override
  final int typeId = 8;

  @override
  CompletionEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletionEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      isCompleted: fields[2] as bool,
      count: fields[3] as int,
      rewardRating: fields[4] as double?,
      syncStatus: fields[5] as SyncStatus,
      updatedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CompletionEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.count)
      ..writeByte(4)
      ..write(obj.rewardRating)
      ..writeByte(5)
      ..write(obj.syncStatus)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CompletionEntryAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompletionEntryImpl _$$CompletionEntryImplFromJson(Map<String, dynamic> json) => _$CompletionEntryImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      isCompleted: json['isCompleted'] as bool,
      count: (json['count'] as num?)?.toInt() ?? 1,
      rewardRating: (json['rewardRating'] as num?)?.toDouble(),
      syncStatus: $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ?? SyncStatus.synced,
      updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CompletionEntryImplToJson(_$CompletionEntryImpl instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'count': instance.count,
      'rewardRating': instance.rewardRating,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
  SyncStatus.deleted: 'deleted',
};
