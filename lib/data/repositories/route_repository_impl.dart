import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/repositories/route_repository.dart';
import '../datasources/route_local_datasource.dart';
import '../models/route_model.dart';
import '../models/location_point_model.dart';

class RouteRepositoryImpl implements RouteRepository {
  final RouteLocalDataSource localDataSource;

  RouteRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> saveRoute(Route route) async {
    try {
      final routeModel = RouteModel.fromEntity(route);
      await localDataSource.saveRoute(routeModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to save route: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Route>>> getAllRoutes() async {
    try {
      final routes = await localDataSource.getAllRoutes();
      return Right(routes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get routes: $e'));
    }
  }

  @override
  Future<Either<Failure, Route>> getRouteById(String id) async {
    try {
      final route = await localDataSource.getRouteById(id);
      return Right(route);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get route: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoute(String id) async {
    try {
      await localDataSource.deleteRoute(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to delete route: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addPointToRoute(
    String routeId,
    LocationPoint point,
  ) async {
    try {
      final route = await localDataSource.getRouteById(routeId);
      final pointModel = LocationPointModel.fromEntity(point);
      final updatedPoints = List<LocationPointModel>.from(route.pointModels)
        ..add(pointModel);
      
      final updatedRoute = RouteModel(
        id: route.id,
        name: route.name,
        pointModels: updatedPoints,
        startTime: route.startTime,
        endTime: route.endTime,
        totalDistance: route.totalDistance,
        durationInSeconds: route.durationInSeconds,
        averageSpeed: route.averageSpeed,
        maxSpeed: route.maxSpeed,
      );
      
      await localDataSource.updateRoute(updatedRoute);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to add point to route: $e'));
    }
  }

  @override
  Future<Either<Failure, Route>> updateRoute(Route route) async {
    try {
      final routeModel = RouteModel.fromEntity(route);
      await localDataSource.updateRoute(routeModel);
      return Right(route);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to update route: $e'));
    }
  }
}
