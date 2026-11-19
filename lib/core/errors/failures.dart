import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

class LocationServiceFailure extends Failure {
  const LocationServiceFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
