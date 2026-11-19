import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/location_point.dart';

abstract class LocationRepository {
  Future<Either<Failure, LocationPoint>> getCurrentLocation();
  
  Stream<Either<Failure, LocationPoint>> getLocationStream({
    int distanceFilter = 10,
  });
  
  Future<Either<Failure, bool>> checkLocationPermission();
  Future<Either<Failure, bool>> requestLocationPermission();
  Future<Either<Failure, bool>> checkLocationService();
  Future<Either<Failure, void>> openLocationSettings();
}
