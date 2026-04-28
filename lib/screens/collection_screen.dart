import 'package:flutter/material.dart';
import 'package:frames_app/models/door_model.dart';

class CollectionScreen extends StatelessWidget {
  final List<Door> doors;
  final List<String> foundDoorIds;

  const CollectionScreen({
    super.key,
    required this.doors,
    required this.foundDoorIds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: const Center(
        child: Text('Collection coming soon'),
      ),
    );
  }
}