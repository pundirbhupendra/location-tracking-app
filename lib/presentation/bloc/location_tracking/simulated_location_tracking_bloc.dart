import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/location_point.dart';
import '../../../domain/entities/tracking_session.dart';
import '../../../core/utils/location_utils.dart';
import '../../../core/utils/route_simulator.dart';
import 'location_tracking_bloc.dart';
import 'location_tracking_event.dart';
import 'location_tracking_state.dart';

class SimulatedLocationTrackingBloc extends LocationTrackingBloc {
  final Uuid uuid = const Uuid();
  final RouteSimulator _routeSimulator = RouteSimulator();
  
  DateTime? _startTime;
  final List<LocationPoint> _routePoints = [];
  final List<double> _speedHistory = [];
  double _totalDistance = 0.0;
  Timer? _autoSimTimer;
  
  final int _pointsToIgnore = 3;
  final double _maxAccuracyThreshold = 50.0;
  final double _maxSpeedThreshold = 500.0;
  final double _idleSpeedThreshold = 0.5;
  final int _speedHistoryLimit = 5;

  SimulatedLocationTrackingBloc() : super(TrackingInitial()) {
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<PauseTracking>(_onPauseTracking);
    on<ResumeTracking>(_onResumeTracking);
    on<SimulateMovement>(_onSimulateMovement);
    on<ToggleAutoSimulation>(_onToggleAutoSimulation);
    on<SimulateGpsJump>(_onSimulateGpsJump);
    on<LocationUpdated>(_onLocationUpdated);
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<LocationTrackingState> emit,
  ) async {
    _startTime = DateTime.now();
    _routePoints.clear();
    _totalDistance = 0.0;
    _speedHistory.clear();
    _routeSimulator.reset();

    final session = TrackingSession(
      id: uuid.v4(),
      status: TrackingStatus.tracking,
      startTime: _startTime,
    );

    emit(TrackingInProgress(
      session: session,
      routePoints: [],
    ));
    
    // Auto-start simulation
    add(ToggleAutoSimulation());
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<LocationTrackingState> emit,
  ) async {
    _autoSimTimer?.cancel();
    _autoSimTimer = null;

    if (state is TrackingInProgress || state is TrackingPaused) {
      final currentState = state;
      TrackingSession session;
      
      if (currentState is TrackingInProgress) {
        session = currentState.session;
      } else {
        session = (currentState as TrackingPaused).session;
      }

      final stoppedSession = session.copyWith(
        status: TrackingStatus.stopped,
        lastUpdateTime: DateTime.now(),
        distanceCovered: _totalDistance,
      );

      emit(TrackingStopped(
        session: stoppedSession,
        routePoints: List.from(_routePoints),
      ));
    } else {
      emit(TrackingStopped(
        session: TrackingSession(
            id: uuid.v4(),
            status: TrackingStatus.stopped,
            startTime: DateTime.now()),
        routePoints: [],
      ));
    }
  }

  Future<void> _onPauseTracking(
    PauseTracking event,
    Emitter<LocationTrackingState> emit,
  ) async {
    _autoSimTimer?.cancel();

    if (state is TrackingInProgress) {
      final currentState = state as TrackingInProgress;
      final pausedSession = currentState.session.copyWith(
        status: TrackingStatus.paused,
      );

      emit(TrackingPaused(
        session: pausedSession,
        routePoints: List.from(_routePoints),
      ));
    }
  }

  Future<void> _onResumeTracking(
    ResumeTracking event,
    Emitter<LocationTrackingState> emit,
  ) async {
    if (state is TrackingPaused) {
      // Resume simulation
      add(ToggleAutoSimulation());
      
      final currentState = state as TrackingPaused;
      final resumedSession = currentState.session.copyWith(
        status: TrackingStatus.tracking,
      );
      
      emit(TrackingInProgress(
        session: resumedSession,
        routePoints: List.from(_routePoints),
        currentLocation: _routePoints.isNotEmpty ? _routePoints.last : null,
      ));
    }
  }

  Future<void> _onSimulateMovement(
    SimulateMovement event,
    Emitter<LocationTrackingState> emit,
  ) async {
    if (state is! TrackingInProgress) {
       // If not tracking, start it
       add(const StartTracking());
       await Future.delayed(const Duration(milliseconds: 100));
    }

    final stepData = _routeSimulator.nextStep();

    if (stepData == null) {
      _autoSimTimer?.cancel();
      _autoSimTimer = null;
      add(StopTracking());
      return;
    }

    add(LocationUpdated(
      latitude: stepData['latitude'],
      longitude: stepData['longitude'],
      speed: stepData['speed'],
      heading: stepData['heading'],
      accuracy: stepData['accuracy'],
      batteryLevel: stepData['batteryLevel'],
    ));
  }

  Future<void> _onToggleAutoSimulation(
    ToggleAutoSimulation event,
    Emitter<LocationTrackingState> emit,
  ) async {
    if (_autoSimTimer != null && _autoSimTimer!.isActive) {
      _autoSimTimer?.cancel();
      _autoSimTimer = null;
    } else {
      _autoSimTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(SimulateMovement());
      });
    }
  }

  Future<void> _onSimulateGpsJump(
    SimulateGpsJump event,
    Emitter<LocationTrackingState> emit,
  ) async {
    if (state is! TrackingInProgress) return;
    
    final currentLat = (state as TrackingInProgress).currentLocation?.latitude ?? 37.7749;
    final currentLng = (state as TrackingInProgress).currentLocation?.longitude ?? -122.4194;

    add(LocationUpdated(
      latitude: currentLat + 0.05,
      longitude: currentLng + 0.05,
      speed: 1000.0,
      heading: 0,
      accuracy: 100.0,
      batteryLevel: 80,
    ));
  }

  Future<void> _onLocationUpdated(
    LocationUpdated event,
    Emitter<LocationTrackingState> emit,
  ) async {
    if (state is! TrackingInProgress) return;

    if (_routePoints.length < _pointsToIgnore) {
      _routePoints.add(LocationPoint(
        id: uuid.v4(),
        latitude: event.latitude,
        longitude: event.longitude,
        speed: event.speed,
        heading: event.heading,
        accuracy: event.accuracy,
        batteryLevel: event.batteryLevel,
        timestamp: DateTime.now(),
      ));
      return;
    }

    if (event.accuracy != null && event.accuracy! > _maxAccuracyThreshold) {
      return;
    }

    final currentState = state as TrackingInProgress;
    final now = DateTime.now();

    if (_routePoints.isNotEmpty) {
      final lastPoint = _routePoints.last;
      final distance = LocationUtils.calculateDistance(
        lastPoint.latitude,
        lastPoint.longitude,
        event.latitude,
        event.longitude,
      );
      final timeDiff = now.difference(lastPoint.timestamp).inSeconds;
      if (timeDiff > 0) {
        final calculatedSpeed = distance / timeDiff;
        if (calculatedSpeed > _maxSpeedThreshold) {
          return;
        }
      }

      if (event.speed != null && event.speed! < _idleSpeedThreshold) {
      }

      _totalDistance += distance;
    }

    double smoothedSpeed = event.speed ?? 0.0;
    if (event.speed != null) {
      _speedHistory.add(event.speed!);
      if (_speedHistory.length > _speedHistoryLimit) {
        _speedHistory.removeAt(0);
      }
      smoothedSpeed =
          _speedHistory.reduce((a, b) => a + b) / _speedHistory.length;
    }

    final newPoint = LocationPoint(
      id: uuid.v4(),
      latitude: event.latitude,
      longitude: event.longitude,
      speed: smoothedSpeed,
      heading: event.heading,
      accuracy: event.accuracy,
      batteryLevel: event.batteryLevel,
      timestamp: now,
    );

    _routePoints.add(newPoint);

    final activeDuration = now.difference(_startTime ?? now);

    final updatedSession = currentState.session.copyWith(
      lastUpdateTime: now,
      distanceCovered: _totalDistance,
      activeDuration: activeDuration,
      pointsCount: _routePoints.length,
    );

    emit(TrackingInProgress(
      session: updatedSession,
      currentLocation: newPoint,
      routePoints: List.from(_routePoints),
    ));
  }
}
