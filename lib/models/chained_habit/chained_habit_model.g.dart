// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chained_habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChainedHabitAdapter extends TypeAdapter<ChainedHabit> {
  @override
  final int typeId = 1;

  @override
  ChainedHabit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChainedHabit(
      chainName: fields[0] as String,
      description: fields[1] as String?,
      firstHabit: fields[2] as Habit?,
      mainHabit: fields[3] as Habit,
      secondHabit: fields[4] as Habit?,
    );
  }

  @override
  void write(BinaryWriter writer, ChainedHabit obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.chainName)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.firstHabit)
      ..writeByte(3)
      ..write(obj.mainHabit)
      ..writeByte(4)
      ..write(obj.secondHabit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainedHabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
