import 'package:equatable/equatable.dart';
import '../../../domain/entities/location_point.dart';
import '../../../domain/entities/tracking_session.dart';

abstract class LocationTrackingState extends Equatable {
  const LocationTrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingInitial extends LocationTrackingState {}

class TrackingInProgress extends LocationTrackingState {
  final TrackingSession session;
  final LocationPoint? currentLocation;
  final List<LocationPoint> routePoints;

  const TrackingInProgress({
    required this.session,
    this.currentLocation,
    required this.routePoints,
  });

  @override
  List<Object?> get props => [session, currentLocation, routePoints];
}

class TrackingPaused extends LocationTrackingState {
  final TrackingSession session;
  final List<LocationPoint> routePoints;

  const TrackingPaused({
    required this.session,
    required this.routePoints,
  });

  @override
  List<Object?> get props => [session, routePoints];
}

class TrackingStopped extends LocationTrackingState {
  final TrackingSession session;
  final List<LocationPoint> routePoints;

  const TrackingStopped({
    required this.session,
    required this.routePoints,
  });

  @override
  List<Object?> get props => [session, routePoints];
}

class TrackingError extends LocationTrackingState {
  final String message;

  const TrackingError(this.message);

  @override
  List<Object> get props => [message];
}
