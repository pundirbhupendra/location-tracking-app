import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/location_point.dart';
import '../repositories/location_repository.dart';

class StartTracking {
  final LocationRepository repository;

  StartTracking(this.repository);

  Stream<Either<Failure, LocationPoint>> call({
    int distanceFilter = 10,
  }) {
    return repository.getLocationStream(distanceFilter: distanceFilter);
  }
}
