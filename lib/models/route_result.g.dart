// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RouteResultAdapter extends TypeAdapter<RouteResult> {
  @override
  final int typeId = 2;

  @override
  RouteResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RouteResult(
      id: fields[0] as String,
      originLabel: fields[1] as String,
      destinationLabel: fields[2] as String,
      stopLabels: (fields[3] as List).cast<String>(),
      summary: fields[4] as String,
      searchedAt: fields[5] as DateTime,
      originalQuery: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RouteResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originLabel)
      ..writeByte(2)
      ..write(obj.destinationLabel)
      ..writeByte(3)
      ..write(obj.stopLabels)
      ..writeByte(4)
      ..write(obj.summary)
      ..writeByte(5)
      ..write(obj.searchedAt)
      ..writeByte(6)
      ..write(obj.originalQuery);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
