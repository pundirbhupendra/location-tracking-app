import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/check_location_permission.dart';
import '../../../domain/usecases/request_location_permission.dart';
import '../../../domain/usecases/check_location_service.dart';
import '../../../domain/usecases/open_location_settings.dart';
import 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> {
  final CheckLocationPermission checkPermission;
  final RequestLocationPermission requestPermission;
  final CheckLocationService checkService;
  final OpenLocationSettings openSettings;

  PermissionCubit({
    required this.checkPermission,
    required this.requestPermission,
    required this.checkService,
    required this.openSettings,
  }) : super(PermissionState.initial());

  Future<void> check() async {
    emit(state.copyWith(status: PermissionStatus.checking));

    final serviceResult = await checkService();
    
    await serviceResult.fold(
      (failure) {
        emit(state.copyWith(
          status: PermissionStatus.serviceDisabled,
          errorMessage: failure.message,
        ));
      },
      (isEnabled) async {
        if (!isEnabled) {
          emit(state.copyWith(
            status: PermissionStatus.serviceDisabled,
            errorMessage: 'Location service is disabled',
          ));
          return;
        }

        final permissionResult = await checkPermission();
        
        permissionResult.fold(
          (failure) {
            emit(state.copyWith(
              status: PermissionStatus.denied,
              errorMessage: failure.message,
            ));
          },
          (isGranted) {
            if (isGranted) {
              emit(state.copyWith(status: PermissionStatus.granted));
            } else {
              emit(state.copyWith(status: PermissionStatus.denied));
            }
          },
        );
      },
    );
  }

  Future<void> request() async {
    emit(state.copyWith(status: PermissionStatus.checking));

    final result = await requestPermission();
    
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: PermissionStatus.denied,
          errorMessage: failure.message,
        ));
      },
      (isGranted) {
        if (isGranted) {
          emit(state.copyWith(status: PermissionStatus.granted));
        } else {
          emit(state.copyWith(status: PermissionStatus.deniedForever));
        }
      },
    );
  }

  Future<void> openDeviceSettings() async {
    await openSettings();
  }
}
