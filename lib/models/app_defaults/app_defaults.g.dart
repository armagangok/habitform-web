// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_defaults.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppDefaultsAdapter extends TypeAdapter<AppDefaults> {
  @override
  final int typeId = 6;

  @override
  AppDefaults read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppDefaults(
      isAppOpenedFirstTime: fields[0] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, AppDefaults obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.isAppOpenedFirstTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppDefaultsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
