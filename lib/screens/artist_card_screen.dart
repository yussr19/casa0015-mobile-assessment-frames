import 'package:flutter/material.dart';
import 'package:frames_app/models/door_model.dart';

class ArtistCardScreen extends StatelessWidget {
  final Door door;

  const ArtistCardScreen({super.key, required this.door});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1208),
      body: const Center(
        child: Text(
          'Artist card coming soon',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}