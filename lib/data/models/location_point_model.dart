// ignore_for_file: overridden_fields

import 'package:hive/hive.dart';
import '../../domain/entities/location_point.dart';

part 'location_point_model.g.dart';

@HiveType(typeId: 0)
class LocationPointModel extends LocationPoint {
  @override
  @HiveField(0)
  final String id;
  
  @override
  @HiveField(1)
  final double latitude;
  
  @override
  @HiveField(2)
  final double longitude;
  
  @override
  @HiveField(3)
  final double? altitude;
  
  @override
  @HiveField(4)
  final double? accuracy;
  
  @override
  @HiveField(5)
  final double? speed;
  
  @override
  @HiveField(6)
  final double? heading;

  @override
  @HiveField(7)
  final int? batteryLevel;

  @override
  @HiveField(8)
  final DateTime timestamp;

  const LocationPointModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
    this.batteryLevel,
    required this.timestamp,
  }) : super(
          id: id,
          latitude: latitude,
          longitude: longitude,
          altitude: altitude,
          accuracy: accuracy,
          speed: speed,
          heading: heading,
          batteryLevel: batteryLevel,
          timestamp: timestamp,
        );

  factory LocationPointModel.fromEntity(LocationPoint entity) {
    return LocationPointModel(
      id: entity.id,
      latitude: entity.latitude,
      longitude: entity.longitude,
      altitude: entity.altitude,
      accuracy: entity.accuracy,
      speed: entity.speed,
      heading: entity.heading,
      batteryLevel: entity.batteryLevel,
      timestamp: entity.timestamp,
    );
  }

  factory LocationPointModel.fromPosition(
    String id,
    double latitude,
    double longitude, {
    double? altitude,
    double? accuracy,
    double? speed,
    double? heading,
    int? batteryLevel,
  }) {
    return LocationPointModel(
      id: id,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      accuracy: accuracy,
      speed: speed,
      heading: heading,
      batteryLevel: batteryLevel,
      timestamp: DateTime.now(),
    );
  }
}
