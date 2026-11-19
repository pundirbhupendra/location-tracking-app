import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/location_point.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocation {
  final LocationRepository repository;

  GetCurrentLocation(this.repository);

  Future<Either<Failure, LocationPoint>> call() async {
    return await repository.getCurrentLocation();
  }
}
