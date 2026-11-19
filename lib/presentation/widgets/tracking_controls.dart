import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/location_tracking/location_tracking_bloc.dart';
import '../bloc/location_tracking/location_tracking_event.dart';
import '../bloc/location_tracking/location_tracking_state.dart';

class TrackingControls extends StatelessWidget {
  const TrackingControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationTrackingBloc, LocationTrackingState>(
      builder: (context, state) {
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildControls(context, state),
          ),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context, LocationTrackingState state) {
    if (state is TrackingInitial || state is TrackingStopped) {
      return _buildStartButtons(context);
    }

    if (state is TrackingInProgress) {
      return _buildActiveControls(context);
    }

    if (state is TrackingPaused) {
      return _buildPausedControls(context);
    }

    if (state is TrackingError) {
      return _buildErrorControls(context, state.message);
    }

    return const SizedBox.shrink();
  }

  Widget _buildStartButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<LocationTrackingBloc>().add(const StartTracking());
            },
            icon: const Icon(Icons.location_on),
            label: const Text('Start Real Tracking'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final bloc = context.read<LocationTrackingBloc>();
              bloc.add(const StartTracking());
              Future.delayed(const Duration(milliseconds: 500), () {
                bloc.add(ToggleAutoSimulation());
              });
            },
            icon: const Icon(Icons.fastfood, size: 28),
            label: const Text(
              'Simulate Food Delivery',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveControls(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<LocationTrackingBloc>().add(PauseTracking());
            },
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<LocationTrackingBloc>().add(StopTracking());
            },
            icon: const Icon(Icons.stop),
            label: const Text('Stop'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            FloatingActionButton.small(
              heroTag: 'manual_step',
              onPressed: () {
                context.read<LocationTrackingBloc>().add(SimulateMovement());
              },
              backgroundColor: Colors.blue,
              tooltip: 'Manual Step',
              child: const Icon(Icons.directions_run, color: Colors.white),
            ),
            const SizedBox(height: 4),
            FloatingActionButton.small(
              heroTag: 'sim_jump',
              onPressed: () {
                context.read<LocationTrackingBloc>().add(SimulateGpsJump());
              },
              backgroundColor: Colors.orange,
              tooltip: 'Simulate GPS Jump',
              child: const Icon(Icons.warning_amber, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPausedControls(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<LocationTrackingBloc>().add(ResumeTracking());
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<LocationTrackingBloc>().add(StopTracking());
            },
            icon: const Icon(Icons.stop),
            label: const Text('Stop'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorControls(BuildContext context, String message) {
    return Column(
      children: [
        Text(
          message,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<LocationTrackingBloc>().add(const StartTracking());
            },
            child: const Text('Try Again'),
          ),
        ),
      ],
    );
  }
}
