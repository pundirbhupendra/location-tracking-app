/// Base exception class
class AppException implements Exception {
  final String message;
  
  AppException(this.message);
  
  @override
  String toString() => message;
}

class LocationException extends AppException {
  LocationException(super.message);
}

class LocationServiceException extends AppException {
  LocationServiceException(super.message);
}

class PermissionException extends AppException {
  PermissionException(super.message);
}

class CacheException extends AppException {
  CacheException(super.message);
}
