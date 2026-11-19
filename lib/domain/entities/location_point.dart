import 'package:equatable/equatable.dart';

class LocationPoint extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final int? batteryLevel;
  final DateTime timestamp;

  const LocationPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
    this.batteryLevel,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        latitude,
        longitude,
        altitude,
        accuracy,
        speed,
        heading,
        batteryLevel,
        timestamp,
      ];
}
