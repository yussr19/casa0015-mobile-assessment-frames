import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frames_app/models/door_model.dart';
import 'package:frames_app/services/firestore_service.dart';

class QrScannerScreen extends StatefulWidget {
  final List<Door> doors;
  final Function(String) onDoorScanned;

  const QrScannerScreen({
    super.key,
    required this.doors,
    required this.onDoorScanned,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController _scannerController = MobileScannerController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _hasScanned = false;
  bool _isDetected = false;
  String? _detectedDoorName;

  // spark animation
  late AnimationController _sparkController;
  late Animation<double> _sparkAnimation;

  @override
  void initState() {
    super.initState();
    _sparkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _sparkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sparkController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;

    final barcode = capture.barcodes.first;
    final value = barcode.rawValue;
    if (value == null) return;

    // check if this matches one of our door qr codes
    Door? matchedDoor;
    for (final door in widget.doors) {
      if (door.qrValue == value) {
        matchedDoor = door;
        break;
      }
    }

    if (matchedDoor == null) return;

    setState(() {
      _hasScanned = true;
      _isDetected = true;
      _detectedDoorName = matchedDoor!.street;
    });

    // haptic feedback - double pulse like a real unlock
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.heavyImpact();

    // spark animation
    _sparkController.forward();

    // save to firestore
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _firestoreService.markDoorFound(userId, matchedDoor.id);

    // tell map screen to update
    widget.onDoorScanned(matchedDoor.id);

    // wait then navigate back
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // camera viewfinder
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Scan Door',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // torch button
                  GestureDetector(
                    onTap: () => _scannerController.toggleTorch(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // hint text
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 0,
            right: 0,
            child: Text(
              _isDetected
                  ? 'Door unlocked! 🎉'
                  : 'Point at the QR code on the door',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isDetected
                    ? const Color(0xFF40E060)
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // QR finder box in centre
          Center(
            child: AnimatedBuilder(
              animation: _sparkAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // finder box
                    CustomPaint(
                      size: const Size(220, 220),
                      painter: FinderPainter(
                        isDetected: _isDetected,
                        sparkValue: _sparkAnimation.value,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // detected confirmation pill
          if (_isDetected && _detectedDoorName != null)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF40E060).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '✓ $_detectedDoorName · unlocking...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          // bottom hint
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              '${widget.doors.length} doors in Liverpool',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// draws the QR finder corners and spark effect
class FinderPainter extends CustomPainter {
  final bool isDetected;
  final double sparkValue;

  FinderPainter({required this.isDetected, required this.sparkValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cornerColor = isDetected
        ? const Color(0xFF40E060)
        : Colors.white;
    final cornerPaint = Paint()
      ..color = cornerColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cornerSize = 28.0;
    final w = size.width;
    final h = size.height;

    // top left
    canvas.drawLine(Offset(0, cornerSize), Offset(0, 0), cornerPaint);
    canvas.drawLine(Offset(0, 0), Offset(cornerSize, 0), cornerPaint);

    // top right
    canvas.drawLine(Offset(w - cornerSize, 0), Offset(w, 0), cornerPaint);
    canvas.drawLine(Offset(w, 0), Offset(w, cornerSize), cornerPaint);

    // bottom left
    canvas.drawLine(Offset(0, h - cornerSize), Offset(0, h), cornerPaint);
    canvas.drawLine(Offset(0, h), Offset(cornerSize, h), cornerPaint);

    // bottom right
    canvas.drawLine(
        Offset(w - cornerSize, h), Offset(w, h), cornerPaint);
    canvas.drawLine(
        Offset(w, h - cornerSize), Offset(w, h), cornerPaint);

    // green box outline when detected
    if (isDetected) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()
          ..color = const Color(0xFF40E060).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // sparks radiating from corners
      if (sparkValue > 0) {
        _drawSparks(canvas, size);
      }
    } else {
      // scan line animation - just use a simple line
      final scanY = h * (sparkValue == 0 ? 0.5 : sparkValue);
      canvas.drawLine(
        Offset(4, scanY),
        Offset(w - 4, scanY),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawSparks(Canvas canvas, Size size) {
    final sparkPaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final corners = [
      Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];

    final sparkDirections = [
      [Offset(-1, -1), Offset(-0.5, -1), Offset(-1, -0.5)],
      [Offset(1, -1), Offset(0.5, -1), Offset(1, -0.5)],
      [Offset(-1, 1), Offset(-0.5, 1), Offset(-1, 0.5)],
      [Offset(1, 1), Offset(0.5, 1), Offset(1, 0.5)],
    ];

    for (int i = 0; i < corners.length; i++) {
      for (final dir in sparkDirections[i]) {
        final length = 20.0 * sparkValue;
        final opacity = (1 - sparkValue).clamp(0.0, 1.0);
        // alternate yellow and orange sparks
        sparkPaint.color = (i % 2 == 0
            ? const Color(0xFFFFD700)
            : const Color(0xFFFF8C00))
            .withValues(alpha: opacity);
        canvas.drawLine(
          corners[i],
          corners[i] + Offset(dir.dx * length, dir.dy * length),
          sparkPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant FinderPainter oldDelegate) =>
      oldDelegate.isDetected != isDetected ||
      oldDelegate.sparkValue != sparkValue;
}