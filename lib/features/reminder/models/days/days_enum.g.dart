// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'days_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DaysAdapter extends TypeAdapter<Days> {
  @override
  final int typeId = 8;

  @override
  Days read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Days.mon;
      case 1:
        return Days.tue;
      case 2:
        return Days.wed;
      case 3:
        return Days.thu;
      case 4:
        return Days.fri;
      case 5:
        return Days.sat;
      case 6:
        return Days.sun;
      default:
        return Days.mon;
    }
  }

  @override
  void write(BinaryWriter writer, Days obj) {
    switch (obj) {
      case Days.mon:
        writer.writeByte(0);
        break;
      case Days.tue:
        writer.writeByte(1);
        break;
      case Days.wed:
        writer.writeByte(2);
        break;
      case Days.thu:
        writer.writeByte(3);
        break;
      case Days.fri:
        writer.writeByte(4);
        break;
      case Days.sat:
        writer.writeByte(5);
        break;
      case Days.sun:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DaysAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
