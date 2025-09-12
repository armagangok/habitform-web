// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multiple_reminder_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MultipleReminderModelAdapter extends TypeAdapter<MultipleReminderModel> {
  @override
  final int typeId = 77;

  @override
  MultipleReminderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MultipleReminderModel(
      id: fields[0] as int,
      reminderTimes: (fields[1] as List).cast<DateTime>(),
      days: (fields[2] as List?)?.cast<Days>(),
    );
  }

  @override
  void write(BinaryWriter writer, MultipleReminderModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reminderTimes)
      ..writeByte(2)
      ..write(obj.days);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultipleReminderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
