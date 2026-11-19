import 'package:flutter/material.dart';

class DeliveryCompletedDialog extends StatelessWidget {
  final double distanceKm;
  final int durationMinutes;
  final int batterySaved;
  final VoidCallback? onNewOrder;

  const DeliveryCompletedDialog({
    super.key,
    required this.distanceKm,
    required this.durationMinutes,
    required this.batterySaved,
    this.onNewOrder,
  });


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, color: Colors.green, size: 60),
          SizedBox(height: 16),
          Text(
            'Cycle Completed!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: Text(
        'The delivery simulation has finished successfully.\n\n'
        '• Distance: ${distanceKm.toStringAsFixed(1)} km\n'
        '• Time: $durationMinutes min\n'
        '• Battery Saved: $batterySaved%',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            if (onNewOrder != null) onNewOrder!();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'New Order',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required double distanceKm,
    required int durationMinutes,
    required int batterySaved,
    VoidCallback? onNewOrder,
  }) {
    showDialog(
      context: context,
      builder: (_) => DeliveryCompletedDialog(
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
        batterySaved: batterySaved,
        onNewOrder: onNewOrder,
      ),
    );
  }
}
