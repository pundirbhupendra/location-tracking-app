import 'package:get_it/get_it.dart';
import '../../data/datasources/location_local_datasource.dart';
import '../../data/datasources/route_local_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../data/repositories/route_repository_impl.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/route_repository.dart';
import '../../domain/usecases/check_location_permission.dart';
import '../../domain/usecases/request_location_permission.dart';
import '../../domain/usecases/check_location_service.dart';
import '../../domain/usecases/open_location_settings.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/start_tracking.dart';
import '../../presentation/bloc/permission/permission_cubit.dart';
import '../../presentation/bloc/location_tracking/location_tracking_bloc.dart';
import '../../presentation/bloc/location_tracking/simulated_location_tracking_bloc.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Data Sources
  sl.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(),
  );
  
  final routeDataSource = RouteLocalDataSourceImpl();
  await routeDataSource.init();
  sl.registerLazySingleton<RouteLocalDataSource>(() => routeDataSource);

  // Repositories
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(localDataSource: sl()),
  );
  
  sl.registerLazySingleton<RouteRepository>(
    () => RouteRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => CheckLocationPermission(sl()));
  sl.registerLazySingleton(() => RequestLocationPermission(sl()));
  sl.registerLazySingleton(() => CheckLocationService(sl()));
  sl.registerLazySingleton(() => OpenLocationSettings(sl()));
  sl.registerLazySingleton(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton(() => StartTracking(sl()));

  // Blocs & Cubits
  sl.registerFactory(
    () => PermissionCubit(
      checkPermission: sl(),
      requestPermission: sl(),
      checkService: sl(),
      openSettings: sl(),
    ),
  );
  
  // Register SimulatedLocationTrackingBloc as the default implementation for testing
  sl.registerFactory<LocationTrackingBloc>(
    () => SimulatedLocationTrackingBloc(),
  );
}
