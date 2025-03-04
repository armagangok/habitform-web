// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitStatusAdapter extends TypeAdapter<HabitStatus> {
  @override
  final int typeId = 7;

  @override
  HabitStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitStatus.active;
      case 1:
        return HabitStatus.archived;
      default:
        return HabitStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, HabitStatus obj) {
    switch (obj) {
      case HabitStatus.active:
        writer.writeByte(0);
        break;
      case HabitStatus.archived:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
