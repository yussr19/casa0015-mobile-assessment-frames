import 'package:frames_app/screens/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frames_app/models/door_model.dart';
import 'package:frames_app/services/firestore_service.dart';
import 'package:frames_app/screens/qr_scanner_screen.dart';
import 'package:frames_app/screens/collection_screen.dart';
import 'package:frames_app/screens/progress_screen.dart';
import 'package:frames_app/screens/profile_screen.dart';
import 'dart:async';
import 'dart:math';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  final FirestoreService _firestoreService = FirestoreService();

  // liverpool city centre as starting position
  static const LatLng _liverpoolCentre = LatLng(53.4048, -2.9810);

  List<Door> _doors = [];
  List<String> _foundDoorIds = [];
  Set<Marker> _markers = {};
  Position? _currentPosition;
  int _currentIndex = 0;

  // radar animation
  late AnimationController _radarController;
  late Animation<double> _radarAnimation;

  @override
  void initState() {
    super.initState();

    // radar pulse animation
    _radarController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _radarAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeOut),
    );

    _loadData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _loadData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // get all doors and which ones user has found
    final doors = await _firestoreService.getDoors();
    final foundIds = await _firestoreService.getFoundDoors(userId);

    setState(() {
      _doors = doors;
      _foundDoorIds = foundIds;
    });

    _buildMarkers();
  }

  void _buildMarkers() {
    final Set<Marker> markers = {};

    for (final door in _doors) {
      final bool isFound = _foundDoorIds.contains(door.id);

      markers.add(
        Marker(
          markerId: MarkerId(door.id),
          position: LatLng(door.lat, door.lng),
          icon: isFound
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: isFound ? door.street : '???',
            snippet: isFound ? door.neighbourhood : 'Undiscovered door',
          ),
          onTap: () {
            // show door info when tapped
          },
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = position;
        });

        // move camera to user location
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      print('location error: $e');
    }
  }

  // check if any doors are within scanning range (50 metres)
  double _distanceToDoor(Door door) {
    if (_currentPosition == null) return double.infinity;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      door.lat,
      door.lng,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // full screen map
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              // dark map style to match app theme
              _mapController?.setMapStyle(_mapStyle);
            },
            initialCameraPosition: const CameraPosition(
              target: _liverpoolCentre,
              zoom: 15.5,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // radar pulse overlay around user position
          if (_currentPosition != null)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _radarAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RadarPainter(
                      animationValue: _radarAnimation.value,
                    ),
                  );
                },
              ),
            ),

          // location pill at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B4A10),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Liverpool City Centre',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2A1A08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // doors found counter
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1A08).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${_foundDoorIds.length}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE8C060),
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const Text(
                    'found',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFFA08040),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // bottom nav bar
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0D8C8), width: 0.5),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.radar, 'Map', 0),
              _navItem(Icons.grid_view, 'Collection', 1),
              _scanButton(),
              _navItem(Icons.bar_chart, 'Progress', 3),
              _navItem(Icons.person_outline, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 1) {
          Navigator.push(context,
            MaterialPageRoute(builder: (_) => CollectionScreen(
              doors: _doors,
              foundDoorIds: _foundDoorIds,
            )));
        } else if (index == 3) {
          Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProgressScreen()));
        } else if (index == 4) {
          Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive
                ? const Color(0xFF8B4A10)
                : const Color(0xFFAAAAAA),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isActive
                  ? const Color(0xFF8B4A10)
                  : const Color(0xFFAAAAAA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scanButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QrScannerScreen(
              doors: _doors,
              onDoorScanned: (doorId) {
                setState(() {
                  if (!_foundDoorIds.contains(doorId)) {
                    _foundDoorIds.add(doorId);
                  }
                });
                _buildMarkers();
              },
            ),
          ),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF8B4A10),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B4A10).withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

// draws the radar pulse in the centre of the screen
class RadarPainter extends CustomPainter {
  final double animationValue;

  RadarPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.45;

    // two rings with offset timing
    for (int i = 0; i < 2; i++) {
      double progress = (animationValue + i * 0.5) % 1.0;
      double radius = maxRadius * progress;
      double opacity = (1 - progress) * 0.35;

      if (opacity > 0) {
        canvas.drawCircle(
          centre,
          radius,
          Paint()
            ..color = const Color(0xFF8B4A10).withValues(alpha: opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    // small fill in centre area
    canvas.drawCircle(
      centre,
      maxRadius * 0.15,
      Paint()
        ..color = const Color(0xFF8B4A10).withValues(alpha: 0.05),
    );
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// dark map style to match app theme
const String _mapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#d4cdb8"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#3a2a10"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#f5f0e8"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#c8c0a8"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#7a9ab0"}]},
  {"featureType": "poi", "stylers": [{"visibility": "off"}]},
  {"featureType": "transit", "stylers": [{"visibility": "off"}]}
]
''';