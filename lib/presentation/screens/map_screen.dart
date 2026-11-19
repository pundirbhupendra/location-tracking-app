import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/widgets/map/tracking_map_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/permission/permission_cubit.dart';
import '../bloc/permission/permission_state.dart';
import '../bloc/location_tracking/location_tracking_bloc.dart';
import '../bloc/location_tracking/location_tracking_state.dart';
import '../widgets/tracking_controls.dart';
import '../widgets/stats_display.dart';
import '../widgets/map/delivery_status_card.dart';
import '../widgets/map/map_controls.dart';
import '../widgets/map/delivery_details_sheet.dart';
import '../widgets/map/permission_error_view.dart';
import '../widgets/map/show_delivery_completed_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  bool _autoCenter = true;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PermissionCubit, PermissionState>(
        listener: (context, permissionState) {
          if (permissionState.status == PermissionStatus.deniedForever) {
            _showPermissionDialog(context);
          }
        },
        builder: (context, permissionState) {
          if (permissionState.status == PermissionStatus.initial ||
              permissionState.status == PermissionStatus.checking) {
            return const Center(child: CircularProgressIndicator());
          }

          if (permissionState.status == PermissionStatus.serviceDisabled) {
            return PermissionErrorView(
              title: 'Location Service Disabled',
              message: 'Please enable location service in your device settings.',
              onButtonPressed: () => context.read<PermissionCubit>().openDeviceSettings(),
            );
          }

          if (permissionState.status == PermissionStatus.denied) {
            return PermissionErrorView(
              title: 'Location Permission Required',
              message: 'This app needs location permission to track your route.',
              onButtonPressed: () => context.read<PermissionCubit>().request(),
            );
          }

          return _buildMapView();
        },
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        BlocListener<LocationTrackingBloc, LocationTrackingState>(
          listener: (context, trackingState) {
            if (trackingState is TrackingStopped) {
              showDeliveryCompletedDialog(context);
            }
            if (_autoCenter &&
                trackingState is TrackingInProgress &&
                trackingState.currentLocation != null) {
              _animateCamera(
                trackingState.currentLocation!.latitude,
                trackingState.currentLocation!.longitude,
              );
            }
          },
          child: TrackingMapView(
            mapType: _mapType,
            initialPosition: _initialPosition,
            onMapCreated: (controller) => _mapController = controller,
            onCameraMoveStarted: () {
              setState(() {
                _autoCenter = false;
              });
            },
          ),
        ),
        
        MapControls(
          mapType: _mapType,
          showRecenter: !_autoCenter,
          onToggleMapType: () {
            setState(() {
              _mapType = _mapType == MapType.normal 
                  ? MapType.satellite 
                  : MapType.normal;
            });
          },
          onZoomIn: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
          onZoomOut: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
          onRecenter: () {
            setState(() {
              _autoCenter = true;
            });
            final state = context.read<LocationTrackingBloc>().state;
            if (state is TrackingInProgress && state.currentLocation != null) {
              _animateCamera(
                state.currentLocation!.latitude,
                state.currentLocation!.longitude,
              );
            }
          },
        ),

        Positioned(
          bottom: 110,
          left: 16,
          right: 16,
          child: BlocBuilder<LocationTrackingBloc, LocationTrackingState>(
            builder: (context, state) {
              if (state is TrackingInProgress) {
                return DeliveryStatusCard(
                  onTap: () => _showDeliveryDetails(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        
        const Positioned(
          top: 50,
          left: 16,
          right: 16,
          child: StatsDisplay(),
        ),
        
        const Positioned(
          bottom: 30,
          left: 16,
          right: 16,
          child: TrackingControls(),
        ),
      ],
    );
  }

  void _showDeliveryDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DeliveryDetailsSheet(),
    );
  }

  void _animateCamera(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(lat, lng)),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Location permission is permanently denied. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PermissionCubit>().openDeviceSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
