import 'package:equatable/equatable.dart';
import 'location_point.dart';

class Route extends Equatable {
  final String id;
  final String name;
  final List<LocationPoint> points;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistance;
  final Duration duration;
  final double? averageSpeed;
  final double? maxSpeed;

  const Route({
    required this.id,
    required this.name,
    required this.points,
    required this.startTime,
    this.endTime,
    required this.totalDistance,
    required this.duration,
    this.averageSpeed,
    this.maxSpeed,
  });

  bool get isActive => endTime == null;

  @override
  List<Object?> get props => [
        id,
        name,
        points,
        startTime,
        endTime,
        totalDistance,
        duration,
        averageSpeed,
        maxSpeed,
      ];
}
