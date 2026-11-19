import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_local_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDataSource localDataSource;

  LocationRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, LocationPoint>> getCurrentLocation() async {
    try {
      final location = await localDataSource.getCurrentLocation();
      return Right(location);
    } on LocationServiceException catch (e) {
      return Left(LocationServiceFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on LocationException catch (e) {
      return Left(LocationFailure(e.message));
    } catch (e) {
      return Left(LocationFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<Either<Failure, LocationPoint>> getLocationStream({
    int distanceFilter = 10,
  }) {
    try {
      return localDataSource
          .getLocationStream(distanceFilter: distanceFilter)
          .map((location) => Right<Failure, LocationPoint>(location))
          .handleError((error) {
        if (error is LocationServiceException) {
          return Left<Failure, LocationPoint>(
            LocationServiceFailure(error.message),
          );
        } else if (error is PermissionException) {
          return Left<Failure, LocationPoint>(
            PermissionFailure(error.message),
          );
        }
        return Left<Failure, LocationPoint>(
          LocationFailure('Unexpected error: $error'),
        );
      });
    } catch (e) {
      return Stream.value(
        Left(LocationFailure('Failed to start location stream: $e')),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> checkLocationPermission() async {
    try {
      final hasPermission = await localDataSource.checkLocationPermission();
      return Right(hasPermission);
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } catch (e) {
      return Left(PermissionFailure('Failed to check permission: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestLocationPermission() async {
    try {
      final granted = await localDataSource.requestLocationPermission();
      return Right(granted);
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } catch (e) {
      return Left(PermissionFailure('Failed to request permission: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkLocationService() async {
    try {
      final enabled = await localDataSource.checkLocationService();
      return Right(enabled);
    } on LocationServiceException catch (e) {
      return Left(LocationServiceFailure(e.message));
    } catch (e) {
      return Left(LocationServiceFailure('Failed to check service: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> openLocationSettings() async {
    try {
      await localDataSource.openLocationSettings();
      return const Right(null);
    } on LocationServiceException catch (e) {
      return Left(LocationServiceFailure(e.message));
    } catch (e) {
      return Left(LocationServiceFailure('Failed to open settings: $e'));
    }
  }
}
