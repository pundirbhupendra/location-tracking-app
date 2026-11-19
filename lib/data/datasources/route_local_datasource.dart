import 'package:hive/hive.dart';
import '../../core/errors/exceptions.dart';
import '../models/route_model.dart';

abstract class RouteLocalDataSource {
  Future<void> saveRoute(RouteModel route);
  Future<List<RouteModel>> getAllRoutes();
  Future<RouteModel> getRouteById(String id);
  Future<void> deleteRoute(String id);
  Future<void> updateRoute(RouteModel route);
}

class RouteLocalDataSourceImpl implements RouteLocalDataSource {
  static const String _boxName = 'routes';
  Box<RouteModel>? _routeBox;

  Future<void> init() async {
    _routeBox = await Hive.openBox<RouteModel>(_boxName);
  }

  Box<RouteModel> get _box {
    if (_routeBox == null || !_routeBox!.isOpen) {
      throw CacheException('Hive box is not initialized');
    }
    return _routeBox!;
  }

  @override
  Future<void> saveRoute(RouteModel route) async {
    try {
      await _box.put(route.id, route);
    } catch (e) {
      throw CacheException('Failed to save route: $e');
    }
  }

  @override
  Future<List<RouteModel>> getAllRoutes() async {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to get routes: $e');
    }
  }

  @override
  Future<RouteModel> getRouteById(String id) async {
    try {
      final route = _box.get(id);
      if (route == null) {
        throw CacheException('Route not found');
      }
      return route;
    } catch (e) {
      throw CacheException('Failed to get route: $e');
    }
  }

  @override
  Future<void> deleteRoute(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete route: $e');
    }
  }

  @override
  Future<void> updateRoute(RouteModel route) async {
    try {
      await _box.put(route.id, route);
    } catch (e) {
      throw CacheException('Failed to update route: $e');
    }
  }
}
