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
      count: fields[3] == null ? 1 : fields[3] as int,
      rewardRating: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, CompletionEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.count)
      ..writeByte(4)
      ..write(obj.rewardRating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
