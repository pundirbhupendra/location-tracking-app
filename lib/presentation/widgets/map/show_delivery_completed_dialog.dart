import 'package:flutter/material.dart';

void showDeliveryCompletedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 60),
          SizedBox(height: 16),
          Text('Cycle Completed!', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: const Text(
        'The delivery simulation has finished successfully.\n\n'
        '• Distance: 3.2 km\n'
        '• Time: 14 min\n'
        '• Battery Saved: 4%',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('New Order'),
        ),
      ],
    ),
  );
}
