import 'package:equatable/equatable.dart';

enum TrackingStatus {
  idle,
  tracking,
  paused,
  stopped,
}

class TrackingSession extends Equatable {
  final String id;
  final TrackingStatus status;
  final DateTime? startTime;
  final DateTime? lastUpdateTime;
  final double distanceCovered;
  final Duration activeDuration;
  final int pointsCount;

  const TrackingSession({
    required this.id,
    required this.status,
    this.startTime,
    this.lastUpdateTime,
    this.distanceCovered = 0.0,
    this.activeDuration = Duration.zero,
    this.pointsCount = 0,
  });

  TrackingSession copyWith({
    String? id,
    TrackingStatus? status,
    DateTime? startTime,
    DateTime? lastUpdateTime,
    double? distanceCovered,
    Duration? activeDuration,
    int? pointsCount,
  }) {
    return TrackingSession(
      id: id ?? this.id,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      distanceCovered: distanceCovered ?? this.distanceCovered,
      activeDuration: activeDuration ?? this.activeDuration,
      pointsCount: pointsCount ?? this.pointsCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        startTime,
        lastUpdateTime,
        distanceCovered,
        activeDuration,
        pointsCount,
      ];
}
