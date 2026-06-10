// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'correction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CorrectionAdapter extends TypeAdapter<Correction> {
  @override
  final int typeId = 1;

  @override
  Correction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Correction(
      id: fields[0] as String,
      originalName: fields[1] as String,
      correctedName: fields[2] as String,
      correctedGeocode: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Correction obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originalName)
      ..writeByte(2)
      ..write(obj.correctedName)
      ..writeByte(3)
      ..write(obj.correctedGeocode)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CorrectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
