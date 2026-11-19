import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/location_utils.dart';
import '../bloc/location_tracking/location_tracking_bloc.dart';
import '../bloc/location_tracking/location_tracking_state.dart';

class StatsDisplay extends StatelessWidget {
  const StatsDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationTrackingBloc, LocationTrackingState>(
      builder: (context, state) {
        if (state is TrackingInProgress || state is TrackingPaused) {
          final session = state is TrackingInProgress
              ? state.session
              : (state as TrackingPaused).session;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    Icons.battery_std,
                    'Battery',
                    state is TrackingInProgress && state.currentLocation != null
                        ? '${state.currentLocation!.batteryLevel ?? '--'}%'
                        : '--%',
                    Colors.teal,
                  ),
                  _buildDivider(),
                  _buildStat(
                    Icons.straighten,
                    'Distance',
                    LocationUtils.formatDistance(session.distanceCovered),
                    Colors.blue,
                  ),
                  _buildDivider(),
                  _buildStat(
                    Icons.speed,
                    'Speed',
                    state is TrackingInProgress && state.currentLocation != null
                        ? LocationUtils.formatSpeed(state.currentLocation!.speed ?? 0)
                        : '0.0 km/h',
                    Colors.green,
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStat(IconData icon, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey[300],
    );
  }

 
}
