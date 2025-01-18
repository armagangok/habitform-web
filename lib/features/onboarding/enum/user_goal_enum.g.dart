// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_goal_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserGoalAdapter extends TypeAdapter<UserGoal> {
  @override
  final int typeId = 2;

  @override
  UserGoal read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserGoal.betterProductivity;
      case 1:
        return UserGoal.buildRoutine;
      case 2:
        return UserGoal.breakBadHabits;
      case 3:
        return UserGoal.getHealthier;
      case 4:
        return UserGoal.timeManagement;
      case 5:
        return UserGoal.reduceStress;
      case 6:
        return UserGoal.other;
      default:
        return UserGoal.betterProductivity;
    }
  }

  @override
  void write(BinaryWriter writer, UserGoal obj) {
    switch (obj) {
      case UserGoal.betterProductivity:
        writer.writeByte(0);
        break;
      case UserGoal.buildRoutine:
        writer.writeByte(1);
        break;
      case UserGoal.breakBadHabits:
        writer.writeByte(2);
        break;
      case UserGoal.getHealthier:
        writer.writeByte(3);
        break;
      case UserGoal.timeManagement:
        writer.writeByte(4);
        break;
      case UserGoal.reduceStress:
        writer.writeByte(5);
        break;
      case UserGoal.other:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
