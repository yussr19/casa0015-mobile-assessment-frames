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

    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.heavyImpact();

    _sparkController.forward();

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _firestoreService.markDoorFound(userId, matchedDoor.id);

    widget.onDoorScanned(matchedDoor.id);

    final isFirstFinder = await _firestoreService.isFirstFinder(matchedDoor.id, userId);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      if (isFirstFinder) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1208),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFE8C060), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(0xFFE8C060).withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏆',
                        style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    const Text(
                      'First Finder!',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE8C060),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You were the first to discover $_detectedDoorName!',
                      style: const TextStyle(
                        color: Color(0xFFA08040),
                        fontSize: 13,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8C060),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Claim Badge!',
                          style: TextStyle(
                            color: Color(0xFF1A1208),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

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

          Center(
            child: AnimatedBuilder(
              animation: _sparkAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
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
                    color:
                        const Color(0xFF40E060).withValues(alpha: 0.9),
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

class FinderPainter extends CustomPainter {
  final bool isDetected;
  final double sparkValue;

  FinderPainter({required this.isDetected, required this.sparkValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cornerColor =
        isDetected ? const Color(0xFF40E060) : Colors.white;
    final cornerPaint = Paint()
      ..color = cornerColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerSize = 28.0;
    final w = size.width;
    final h = size.height;

    canvas.drawLine(Offset(0, cornerSize), Offset(0, 0), cornerPaint);
    canvas.drawLine(Offset(0, 0), Offset(cornerSize, 0), cornerPaint);
    canvas.drawLine(
        Offset(w - cornerSize, 0), Offset(w, 0), cornerPaint);
    canvas.drawLine(Offset(w, 0), Offset(w, cornerSize), cornerPaint);
    canvas.drawLine(
        Offset(0, h - cornerSize), Offset(0, h), cornerPaint);
    canvas.drawLine(Offset(0, h), Offset(cornerSize, h), cornerPaint);
    canvas.drawLine(
        Offset(w - cornerSize, h), Offset(w, h), cornerPaint);
    canvas.drawLine(
        Offset(w, h - cornerSize), Offset(w, h), cornerPaint);

    if (isDetected) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()
          ..color = const Color(0xFF40E060).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      if (sparkValue > 0) {
        _drawSparks(canvas, size);
      }
    } else {
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