// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'landmark.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LandmarkAdapter extends TypeAdapter<Landmark> {
  @override
  final int typeId = 0;

  @override
  Landmark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Landmark(
      localName: fields[0] as String,
      geocodeQuery: fields[1] as String,
      lat: fields[2] as double?,
      lng: fields[3] as double?,
      verified: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Landmark obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.localName)
      ..writeByte(1)
      ..write(obj.geocodeQuery)
      ..writeByte(2)
      ..write(obj.lat)
      ..writeByte(3)
      ..write(obj.lng)
      ..writeByte(4)
      ..write(obj.verified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LandmarkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
