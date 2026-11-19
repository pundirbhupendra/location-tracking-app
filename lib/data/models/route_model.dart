// ignore_for_file: overridden_fields

import 'package:hive/hive.dart';
import '../../domain/entities/route.dart';
import 'location_point_model.dart';

part 'route_model.g.dart';

@HiveType(typeId: 1)
class RouteModel extends Route {
  @override
  @HiveField(0)
  final String id;
  
  @override
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final List<LocationPointModel> pointModels;
  
  @override
  @HiveField(3)
  final DateTime startTime;
  
  @override
  @HiveField(4)
  final DateTime? endTime;
  
  @override
  @HiveField(5)
  final double totalDistance;
  
  @HiveField(6)
  final int durationInSeconds;
  
  @override
  @HiveField(7)
  final double? averageSpeed;
  
  @override
  @HiveField(8)
  final double? maxSpeed;

  RouteModel({
    required this.id,
    required this.name,
    required this.pointModels,
    required this.startTime,
    this.endTime,
    required this.totalDistance,
    required this.durationInSeconds,
    this.averageSpeed,
    this.maxSpeed,
  }) : super(
          id: id,
          name: name,
          points: pointModels,
          startTime: startTime,
          endTime: endTime,
          totalDistance: totalDistance,
          duration: Duration(seconds: durationInSeconds),
          averageSpeed: averageSpeed,
          maxSpeed: maxSpeed,
        );

  factory RouteModel.fromEntity(Route entity) {
    return RouteModel(
      id: entity.id,
      name: entity.name,
      pointModels: entity.points
          .map((p) => LocationPointModel.fromEntity(p))
          .toList(),
      startTime: entity.startTime,
      endTime: entity.endTime,
      totalDistance: entity.totalDistance,
      durationInSeconds: entity.duration.inSeconds,
      averageSpeed: entity.averageSpeed,
      maxSpeed: entity.maxSpeed,
    );
  }
}
