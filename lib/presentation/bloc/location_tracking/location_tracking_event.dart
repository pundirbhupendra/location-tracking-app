import 'package:equatable/equatable.dart';

abstract class LocationTrackingEvent extends Equatable {
  const LocationTrackingEvent();

  @override
  List<Object?> get props => [];
}

class StartTracking extends LocationTrackingEvent {
  final int distanceFilter;
  
  const StartTracking({this.distanceFilter = 10});
  
  @override
  List<Object?> get props => [distanceFilter];
}

class StopTracking extends LocationTrackingEvent {}

class PauseTracking extends LocationTrackingEvent {}

class ResumeTracking extends LocationTrackingEvent {}

class SimulateMovement extends LocationTrackingEvent {}

class ToggleAutoSimulation extends LocationTrackingEvent {}

class SimulateGpsJump extends LocationTrackingEvent {}

class LocationUpdated extends LocationTrackingEvent {
  final double latitude;
  final double longitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final int? batteryLevel;
  
  const LocationUpdated({
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heading,
    this.accuracy,
    this.batteryLevel,
  });
  
  @override
  List<Object?> get props => [latitude, longitude, speed, heading, accuracy, batteryLevel];
}
