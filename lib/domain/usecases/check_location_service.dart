import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/location_repository.dart';

class CheckLocationService {
  final LocationRepository repository;

  CheckLocationService(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.checkLocationService();
  }
}
