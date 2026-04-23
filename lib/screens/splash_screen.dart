import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_screen.dart';

// first screen the user sees - the door with lion knocker
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _knockController;
  late Animation<double> _knockAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // knocker bounce animation
    _knockController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _knockAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _knockController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _knockController.dispose();
    super.dispose();
  }

  // called when user taps the knocker
  void _handleKnock() async {
    if (_isLoading) return;

    // play knock animation
    await _knockController.forward();
    await _knockController.reverse();
    await _knockController.forward();
    await _knockController.reverse();

    setState(() => _isLoading = true);

    try {
      // sign in anonymously so we can track found doors
      await FirebaseAuth.instance.signInAnonymously();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MapScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      print('sign in error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1208),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // status bar spacer
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDoor(),
              ),
            ),
            // app name and hint at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  Text(
                    'FRAMES',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE8C060),
                      letterSpacing: 6,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLoading ? 'opening...' : 'knock to enter',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF6A5030),
                      letterSpacing: 2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoor() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A0E04),
        border: Border.all(color: const Color(0xFF8B5518), width: 6),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // door split line down the middle
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 2,
                color: const Color(0xFF4A2808),
              ),
            ),
          ),

          Column(
            children: [
              // stained glass window at top
              _buildStainedGlassWindow(),

              // door panels below window
              Expanded(
                child: Row(
                  children: [
                    // left panel
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF120A02),
                          border: Border.all(
                            color: const Color(0xFF4A2808),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    // right panel
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF120A02),
                          border: Border.all(
                            color: const Color(0xFF4A2808),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // lion knocker - positioned at 2/3 down
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.38,
            child: GestureDetector(
              onTap: _handleKnock,
              child: AnimatedBuilder(
                animation: _knockAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _knockAnimation.value),
                    child: child,
                  );
                },
                child: Center(child: _buildLionKnocker()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStainedGlassWindow() {
    return Container(
      height: 180,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF6B3F10), width: 3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: CustomPaint(
          painter: StainedGlassPainter(),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _buildLionKnocker() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [Color(0xFFF0C040), Color(0xFFC08010), Color(0xFF7A4A00)],
        ),
        border: Border.all(color: const Color(0xFF8B6020), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '🦁',
          style: TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}

// paints the stained glass liverpool street grid window
class StainedGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // amber background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFC8780A),
    );

    final colors = [
      const Color(0xFFE8A020),
      const Color(0xFFB85C08),
      const Color(0xFFD4920C),
      const Color(0xFFE8C030),
      const Color(0xFFC06010),
      const Color(0xFFA03808),
      const Color(0xFF8B1A08), // river mersey band
      const Color(0xFFD48818),
      const Color(0xFFB04008),
    ];

    // draw street grid blocks
    double blockH = size.height / 6;
    double blockW = size.width / 5;

    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 5; col++) {
        final paint = Paint()
          ..color = colors[(row * 5 + col) % colors.length];
        canvas.drawRect(
          Rect.fromLTWH(
            col * blockW,
            row * blockH,
            blockW,
            blockH,
          ),
          paint,
        );
      }
    }

    // draw lead lines horizontal
    final leadPaint = Paint()
      ..color = const Color(0xFF1A0C02)
      ..strokeWidth = 2.5;

    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(0, i * blockH),
        Offset(size.width, i * blockH),
        leadPaint,
      );
    }

    // draw lead lines vertical
    for (int i = 1; i < 5; i++) {
      canvas.drawLine(
        Offset(i * blockW, 0),
        Offset(i * blockW, size.height),
        leadPaint,
      );
    }

    // warm glow overlay
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF4C0).withValues(alpha: 0.2),
          const Color(0xFF8B4A00).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}