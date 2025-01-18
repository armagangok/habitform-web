// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_defaults.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDefaultsAdapter extends TypeAdapter<UserDefaults> {
  @override
  final int typeId = 5;

  @override
  UserDefaults read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserDefaults(
      userName: fields[0] as String,
      userGoals: (fields[1] as List?)?.cast<UserGoal>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserDefaults obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.userName)
      ..writeByte(1)
      ..write(obj.userGoals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDefaultsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
