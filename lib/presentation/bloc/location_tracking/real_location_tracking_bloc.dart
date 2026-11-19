import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/location_point.dart';
import '../../../domain/entities/tracking_session.dart';
import '../../../domain/usecases/start_tracking.dart' as usecase;
import '../../../core/utils/location_utils.dart';
import 'location_tracking_bloc.dart';
import 'location_tracking_event.dart';
import 'location_tracking_state.dart';

class RealLocationTrackingBloc extends LocationTrackingBloc {
  final usecase.StartTracking startTrackingUseCase;
  final Uuid uuid = const Uuid();
  
  StreamSubscription<dynamic>? _locationSubscription;
  DateTime? _startTime;
  final List<LocationPoint> _routePoints = [];
  final List<double> _speedHistory = [];
  double _totalDistance = 0.0;
  
  final int _pointsToIgnore = 3;
  final double _maxAccuracyThreshold = 50.0;
  final double _maxSpeedThreshold = 500.0;
  final double _idleSpeedThreshold = 0.5;
  final int _speedHistoryLimit = 5;

  RealLocationTrackingBloc({required this.startTrackingUseCase})
      : super(TrackingInitial()) {
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<PauseTracking>(_onPauseTracking);
    on<ResumeTracking>(_onResumeTracking);
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

    final session = TrackingSession(
      id: uuid.v4(),
      status: TrackingStatus.tracking,
      startTime: _startTime,
    );

    emit(TrackingInProgress(
      session: session,
      routePoints: [],
    ));

    _locationSubscription?.cancel();
    _locationSubscription = startTrackingUseCase(
      distanceFilter: event.distanceFilter,
    ).listen(
      (either) {
        either.fold(
          (failure) {
            add(StopTracking());
            emit(TrackingError(failure.message));
          },
          (locationPoint) {
            add(LocationUpdated(
              latitude: locationPoint.latitude,
              longitude: locationPoint.longitude,
              speed: locationPoint.speed,
              heading: locationPoint.heading,
              accuracy: locationPoint.accuracy,
              batteryLevel: locationPoint.batteryLevel,
            ));
          },
        );
      },
      onError: (error) {
        add(StopTracking());
        emit(TrackingError('Location error: $error'));
      },
    );
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<LocationTrackingState> emit,
  ) async {
    await _locationSubscription?.cancel();

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
    await _locationSubscription?.cancel();

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
      add(const StartTracking());
    }
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

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
