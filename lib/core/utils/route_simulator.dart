import 'dart:math' as math;

class RouteSimulator {
  // San Francisco Route: Market St -> Van Ness -> Fisherman's Wharf
  static final List<Map<String, double>> _simulationRoute = [
    {'lat': 37.7749, 'lng': -122.4194}, // Start (Market St)
    {'lat': 37.7850, 'lng': -122.4210}, // Waypoint 1
    {'lat': 37.7950, 'lng': -122.4230}, // Waypoint 2
    {'lat': 37.8040, 'lng': -122.4245}, // Waypoint 3 (Turn)
    {'lat': 37.8060, 'lng': -122.4200}, // Waypoint 4
    {'lat': 37.8080, 'lng': -122.4177}, // End (Fisherman's Wharf)
  ];

  int _currentWaypointIndex = 0;
  double _segmentProgress = 0.0;
  final double _segmentStep = 0.05; // 5% progress per tick
  
  bool get isFinished => _currentWaypointIndex >= _simulationRoute.length - 1;

  void reset() {
    _currentWaypointIndex = 0;
    _segmentProgress = 0.0;
  }

  Map<String, dynamic>? nextStep() {
    if (isFinished) return null;

    final start = _simulationRoute[_currentWaypointIndex];
    final end = _simulationRoute[_currentWaypointIndex + 1];

    final lat = start['lat']! + (end['lat']! - start['lat']!) * _segmentProgress;
    final lng = start['lng']! + (end['lng']! - start['lng']!) * _segmentProgress;

    // Calculate heading
    final dy = end['lat']! - start['lat']!;
    final dx = end['lng']! - start['lng']!;
    final heading = math.atan2(dx, dy) * 180 / math.pi;

    // Add realistic GPS noise (jitter)
    final noiseLat = (math.Random().nextDouble() - 0.5) * 0.0001; // ~10m noise
    final noiseLng = (math.Random().nextDouble() - 0.5) * 0.0001;

    _segmentProgress += _segmentStep;
    if (_segmentProgress >= 1.0) {
      _segmentProgress = 0.0;
      _currentWaypointIndex++;
    }

    return {
      'latitude': lat + noiseLat,
      'longitude': lng + noiseLng,
      'heading': heading,
      'speed': 15.0 + math.Random().nextDouble() * 5, // 15-20 m/s
      'accuracy': 5.0 + math.Random().nextDouble() * 10, // 5-15m accuracy
      'batteryLevel': 85 - (_currentWaypointIndex * 2),
    };
  }
}
