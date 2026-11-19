import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../bloc/location_tracking/location_tracking_bloc.dart';
import '../../bloc/location_tracking/location_tracking_state.dart';

class TrackingMapView extends StatelessWidget {
  final MapType mapType;
  final Function(GoogleMapController) onMapCreated;
  final VoidCallback onCameraMoveStarted;
  final CameraPosition initialPosition;

  const TrackingMapView({
    super.key,
    required this.mapType,
    required this.onMapCreated,
    required this.onCameraMoveStarted,
    required this.initialPosition,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationTrackingBloc, LocationTrackingState>(
      builder: (context, trackingState) {
        Set<Polyline> polylines = {};
        Set<Marker> markers = {};
        
        if (trackingState is TrackingInProgress || 
            trackingState is TrackingPaused || 
            trackingState is TrackingStopped) {
          
          final List<dynamic> points = trackingState is TrackingInProgress 
              ? trackingState.routePoints 
              : (trackingState is TrackingPaused 
                  ? trackingState.routePoints 
                  : (trackingState as TrackingStopped).routePoints);

          if (points.isNotEmpty) {
            polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: points
                    .map((point) => LatLng(point.latitude, point.longitude))
                    .toList(),
                color: Colors.blue,
                width: 5,
              ),
            );
          }

          if (trackingState is TrackingInProgress && trackingState.currentLocation != null) {
            markers.add(
              Marker(
                markerId: const MarkerId('current_location'),
                position: LatLng(
                  trackingState.currentLocation!.latitude,
                  trackingState.currentLocation!.longitude,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                infoWindow: const InfoWindow(
                  title: 'Delivery Partner',
                  snippet: 'On the way to you',
                ),
              ),
            );
          }

          markers.add(
            Marker(
              markerId: const MarkerId('destination'),
              position: const LatLng(37.8080, -122.4177),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: const InfoWindow(title: 'Delivery Destination'),
            ),
          );
        }

        return GoogleMap(
          initialCameraPosition: initialPosition,
          onMapCreated: onMapCreated,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          polylines: polylines,
          markers: markers,
          mapType: mapType,
          zoomControlsEnabled: false,
          onCameraMoveStarted: onCameraMoveStarted,
        );
      },
    );
  }
}
