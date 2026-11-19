import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/hive_service.dart';
import 'core/services/service_locator.dart';
import 'presentation/bloc/permission/permission_cubit.dart';
import 'presentation/bloc/location_tracking/location_tracking_bloc.dart';
import 'presentation/screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Location Tracking System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<PermissionCubit>()..check()),
          BlocProvider(create: (_) => sl<LocationTrackingBloc>()),
        ],
        child: const MapScreen(),
      ),
    );
  }
}
