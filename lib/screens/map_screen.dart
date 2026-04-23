import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1208),
      body: const Center(
        child: Text(
          'Map coming soon',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}