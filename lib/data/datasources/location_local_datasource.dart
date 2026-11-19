import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:battery_plus/battery_plus.dart';
import '../../core/errors/exceptions.dart';
import '../models/location_point_model.dart';
import 'package:uuid/uuid.dart';

abstract class LocationLocalDataSource {
  Future<LocationPointModel> getCurrentLocation();
  Stream<LocationPointModel> getLocationStream({int distanceFilter = 10});
  Future<bool> checkLocationPermission();
  Future<bool> requestLocationPermission();
  Future<bool> checkLocationService();
  Future<void> openLocationSettings();
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final Uuid uuid = const Uuid();
  final Battery _battery = Battery();

  @override
  Future<LocationPointModel> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceException('Location services are disabled');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw PermissionException('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw PermissionException('Location permission permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final batteryLevel = await _battery.batteryLevel;

      return _positionToModel(position, batteryLevel);
    } catch (e) {
      if (e is LocationServiceException || e is PermissionException) {
        rethrow;
      }
      throw LocationException('Failed to get current location: $e');
    }
  }

  @override
  Stream<LocationPointModel> getLocationStream({
    int distanceFilter = 10,
  }) {
    // Adaptive Tracking Logic:
    // If battery is low (< 20%), increase distance filter to save power.
    // If speed is high (> 20 m/s), decrease distance filter for better accuracy.
    
    return Stream.fromFuture(_battery.batteryLevel).asyncExpand((batteryLevel) {
      int adaptiveFilter = distanceFilter;
      LocationAccuracy accuracy = LocationAccuracy.high;

      if (batteryLevel < 20) {
        adaptiveFilter = distanceFilter * 2;
        accuracy = LocationAccuracy.medium;
      }

      final locationSettings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: adaptiveFilter,
      );

      return Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).asyncMap((position) async {
        final currentBattery = await _battery.batteryLevel;
        return _positionToModel(position, currentBattery);
      });
    });
  }

  @override
  Future<bool> checkLocationPermission() async {
    try {
      var status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      throw PermissionException('Failed to check permission: $e');
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      var status = await Permission.location.request();
      
      if (status.isGranted) {
        final backgroundStatus = await Permission.locationAlways.request();
        return backgroundStatus.isGranted || status.isGranted;
      }
      
      return status.isGranted;
    } catch (e) {
      throw PermissionException('Failed to request permission: $e');
    }
  }

  @override
  Future<bool> checkLocationService() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      throw LocationServiceException('Failed to check service: $e');
    }
  }

  @override
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      throw LocationServiceException('Failed to open settings: $e');
    }
  }

  LocationPointModel _positionToModel(Position position, int batteryLevel) {
    return LocationPointModel.fromPosition(
      uuid.v4(),
      position.latitude,
      position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
      batteryLevel: batteryLevel,
    );
  }
}
