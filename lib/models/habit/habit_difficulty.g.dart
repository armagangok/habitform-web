// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_difficulty.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitDifficultyAdapter extends TypeAdapter<HabitDifficulty> {
  @override
  final int typeId = 10;

  @override
  HabitDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitDifficulty.veryEasy;
      case 1:
        return HabitDifficulty.easy;
      case 2:
        return HabitDifficulty.moderate;
      case 3:
        return HabitDifficulty.difficult;
      case 4:
        return HabitDifficulty.veryDifficult;
      default:
        return HabitDifficulty.veryEasy;
    }
  }

  @override
  void write(BinaryWriter writer, HabitDifficulty obj) {
    switch (obj) {
      case HabitDifficulty.veryEasy:
        writer.writeByte(0);
        break;
      case HabitDifficulty.easy:
        writer.writeByte(1);
        break;
      case HabitDifficulty.moderate:
        writer.writeByte(2);
        break;
      case HabitDifficulty.difficult:
        writer.writeByte(3);
        break;
      case HabitDifficulty.veryDifficult:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
