import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/location_repository.dart';

class OpenLocationSettings {
  final LocationRepository repository;

  OpenLocationSettings(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.openLocationSettings();
  }
}
