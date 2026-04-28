import 'package:flutter/material.dart';
import 'package:frames_app/models/door_model.dart';

class QrScannerScreen extends StatelessWidget {
  final List<Door> doors;
  final Function(String) onDoorScanned;

  const QrScannerScreen({
    super.key,
    required this.doors,
    required this.onDoorScanned,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'QR Scanner coming soon',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
