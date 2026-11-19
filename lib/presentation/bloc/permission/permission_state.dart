import 'package:equatable/equatable.dart';

enum PermissionStatus {
  initial,
  checking,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class PermissionState extends Equatable {
  final PermissionStatus status;
  final String? errorMessage;

  const PermissionState({
    required this.status,
    this.errorMessage,
  });

  factory PermissionState.initial() {
    return const PermissionState(status: PermissionStatus.initial);
  }

  PermissionState copyWith({
    PermissionStatus? status,
    String? errorMessage,
  }) {
    return PermissionState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
