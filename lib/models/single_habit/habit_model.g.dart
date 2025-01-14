// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 2;

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
      completionDates: (fields[5] as List?)?.cast<String>(),
      colorCode: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.completionDates)
      ..writeByte(6)
      ..write(obj.colorCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is HabitAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
