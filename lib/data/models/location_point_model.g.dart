// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_point_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationPointModelAdapter extends TypeAdapter<LocationPointModel> {
  @override
  final int typeId = 0;

  @override
  LocationPointModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationPointModel(
      id: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      altitude: fields[3] as double?,
      accuracy: fields[4] as double?,
      speed: fields[5] as double?,
      heading: fields[6] as double?,
      timestamp: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocationPointModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.altitude)
      ..writeByte(4)
      ..write(obj.accuracy)
      ..writeByte(5)
      ..write(obj.speed)
      ..writeByte(6)
      ..write(obj.heading)
      ..writeByte(7)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationPointModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
