import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/route.dart';
import '../entities/location_point.dart';

abstract class RouteRepository {
  Future<Either<Failure, void>> saveRoute(Route route);
  Future<Either<Failure, List<Route>>> getAllRoutes();
  Future<Either<Failure, Route>> getRouteById(String id);
  Future<Either<Failure, void>> deleteRoute(String id);
  Future<Either<Failure, void>> addPointToRoute(
    String routeId, 
    LocationPoint point
  );
  Future<Either<Failure, Route>> updateRoute(Route route);
}
