import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapControls extends StatelessWidget {
  final MapType mapType;
  final VoidCallback onToggleMapType;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback? onRecenter;
  final bool showRecenter;

  const MapControls({
    super.key,
    required this.mapType,
    required this.onToggleMapType,
    required this.onZoomIn,
    required this.onZoomOut,
    this.onRecenter,
    this.showRecenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 130,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'map_type',
            onPressed: onToggleMapType,
            backgroundColor: Colors.white,
            child: Icon(
              mapType == MapType.normal ? Icons.layers : Icons.map,
              color: Colors.blue,
            ),
          ),
        ),
        
        Positioned(
          bottom: 240,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'zoom_in',
                onPressed: onZoomIn,
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'zoom_out',
                onPressed: onZoomOut,
                backgroundColor: Colors.white,
                child: const Icon(Icons.remove, color: Colors.blue),
              ),
            ],
          ),
        ),

        if (showRecenter && onRecenter != null)
          Positioned(
            bottom: 180,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'recenter',
              onPressed: onRecenter,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
      ],
    );
  }
}
