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
      reminderModel: fields[4] as ReminderModel?,
      emoji: fields[3] as String?,
      completions: fields[7] == null
          ? {}
          : (fields[7] as Map).cast<String, CompletionEntry>(),
      colorCode: fields[6] as int,
      archiveDate: fields[8] as DateTime?,
      status:
          fields[10] == null ? HabitStatus.active : fields[10] as HabitStatus,
      categoryIds:
          fields[11] == null ? [] : (fields[11] as List).cast<String>(),
      difficulty: fields[12] == null
          ? HabitDifficulty.moderate
          : fields[12] as HabitDifficulty,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.difficulty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
