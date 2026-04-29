import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_screen.dart';

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
    _knockController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _knockAnimation = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _knockController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _knockController.dispose();
    super.dispose();
  }

  void _handleKnock() async {
    if (_isLoading) return;
    HapticFeedback.heavyImpact();
    await _knockController.forward();
    await _knockController.reverse();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
    await _knockController.forward();
    await _knockController.reverse();

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInAnonymously();
      final debugUser = FirebaseAuth.instance.currentUser;
      print('SIMULATOR UID: ${debugUser?.uid}');
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
      backgroundColor: const Color(0xFF0D0804),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDoor(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 28, top: 14),
              child: Column(
                children: [
                  const Text(
                    'FRAMES',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE8C060),
                      letterSpacing: 12,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoading ? 'opening...' : 'knock to enter · v1.0',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6A5030),
                      letterSpacing: 3,
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
        border: Border.all(color: const Color(0xFF8B5518), width: 7),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // door centre split
          Positioned.fill(
            child: Center(
              child: Container(width: 3, color: const Color(0xFF5A3010)),
            ),
          ),

          Column(
            children: [
              // stained glass window
              Container(
                height: 220,
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF5A3010),
                    width: 4,
                  ),
                ),
                child: ClipRect(
                  child: CustomPaint(
                    painter: StainedGlassPainter(),
                    size: Size.infinite,
                  ),
                ),
              ),

              // door panels
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10, 8, 5, 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E0602),
                          border: Border.all(
                            color: const Color(0xFF3A2006),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(5, 8, 10, 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E0602),
                          border: Border.all(
                            color: const Color(0xFF3A2006),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // door knocker
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.33,
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
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // backplate
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            center: Alignment(-0.3, -0.3),
                            colors: [
                              Color(0xFFE8C040),
                              Color(0xFFC09010),
                              Color(0xFF8B6200),
                              Color(0xFF5A3E00),
                            ],
                            stops: [0.0, 0.3, 0.7, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4A017)
                                  .withValues(alpha: 0.5),
                              blurRadius: 16,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF2A1800),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                center: Alignment(-0.3, -0.3),
                                colors: [
                                  Color(0xFF5A3E00),
                                  Color(0xFF2A1800),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFFE8C040),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // knocker ring
                      Container(
                        width: 52,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFD700),
                              Color(0xFFC09010),
                              Color(0xFFFFD700),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            color: const Color(0xFF1A0E04),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// liverpool map as stained glass
class StainedGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF020408),
    );

    final fill = Paint()..style = PaintingStyle.fill;
    final lead = Paint()
      ..color = const Color(0xFF080808)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _piece(canvas, fill, lead, [
      Offset(0, h * 0.68),
      Offset(w * 0.15, h * 0.64),
      Offset(w * 0.35, h * 0.66),
      Offset(w * 0.55, h * 0.62),
      Offset(w * 0.75, h * 0.65),
      Offset(w, h * 0.60),
      Offset(w, h * 0.78),
      Offset(w * 0.72, h * 0.82),
      Offset(w * 0.48, h * 0.79),
      Offset(w * 0.25, h * 0.83),
      Offset(0, h * 0.80),
    ], const Color(0xFF0A2A6E));

    _piece(canvas, fill, lead, [
      Offset(w * 0.1, h * 0.70),
      Offset(w * 0.3, h * 0.67),
      Offset(w * 0.28, h * 0.72),
      Offset(w * 0.08, h * 0.74),
    ], const Color(0xFF1A3A8E));

    _piece(canvas, fill, lead, [
      Offset(w * 0.5, h * 0.65),
      Offset(w * 0.7, h * 0.67),
      Offset(w * 0.68, h * 0.72),
      Offset(w * 0.48, h * 0.70),
    ], const Color(0xFF1A3A8E));

    _piece(canvas, fill, lead, [
      Offset(0, h * 0.52),
      Offset(w * 0.14, h * 0.50),
      Offset(w * 0.16, h * 0.64),
      Offset(0, h * 0.68),
    ], const Color(0xFF8B6000));

    _piece(canvas, fill, lead, [
      Offset(0, h * 0.80),
      Offset(w * 0.25, h * 0.83),
      Offset(w * 0.22, h),
      Offset(0, h),
    ], const Color(0xFF7A4800));

    _piece(canvas, fill, lead, [
      Offset(0, h * 0.25),
      Offset(w * 0.12, h * 0.22),
      Offset(w * 0.14, h * 0.50),
      Offset(0, h * 0.52),
    ], const Color(0xFF6B3A00));

    _piece(canvas, fill, lead, [
      Offset(0, 0),
      Offset(w * 0.32, 0),
      Offset(w * 0.30, h * 0.22),
      Offset(w * 0.12, h * 0.22),
      Offset(0, h * 0.25),
    ], const Color(0xFF8B0000));

    _piece(canvas, fill, lead, [
      Offset(w * 0.32, 0),
      Offset(w * 0.62, 0),
      Offset(w * 0.60, h * 0.18),
      Offset(w * 0.42, h * 0.24),
      Offset(w * 0.30, h * 0.22),
    ], const Color(0xFF00006B));

    _piece(canvas, fill, lead, [
      Offset(w * 0.62, 0),
      Offset(w, 0),
      Offset(w, h * 0.20),
      Offset(w * 0.72, h * 0.22),
      Offset(w * 0.60, h * 0.18),
    ], const Color(0xFFB8860B));

    _piece(canvas, fill, lead, [
      Offset(w * 0.12, h * 0.22),
      Offset(w * 0.30, h * 0.22),
      Offset(w * 0.28, h * 0.42),
      Offset(w * 0.14, h * 0.50),
    ], const Color(0xFF005000));

    _piece(canvas, fill, lead, [
      Offset(w * 0.30, h * 0.22),
      Offset(w * 0.42, h * 0.24),
      Offset(w * 0.55, h * 0.38),
      Offset(w * 0.48, h * 0.50),
      Offset(w * 0.28, h * 0.42),
    ], const Color(0xFF7A0000));

    _piece(canvas, fill, lead, [
      Offset(w * 0.42, h * 0.24),
      Offset(w * 0.60, h * 0.18),
      Offset(w * 0.72, h * 0.22),
      Offset(w * 0.68, h * 0.40),
      Offset(w * 0.55, h * 0.38),
    ], const Color(0xFF3A006B));

    _piece(canvas, fill, lead, [
      Offset(w * 0.72, h * 0.22),
      Offset(w, h * 0.20),
      Offset(w, h * 0.48),
      Offset(w * 0.78, h * 0.52),
      Offset(w * 0.68, h * 0.40),
    ], const Color(0xFFD4A010));

    _piece(canvas, fill, lead, [
      Offset(w * 0.14, h * 0.50),
      Offset(w * 0.28, h * 0.42),
      Offset(w * 0.48, h * 0.50),
      Offset(w * 0.45, h * 0.62),
      Offset(w * 0.15, h * 0.64),
    ], const Color(0xFF6B0000));

    _piece(canvas, fill, lead, [
      Offset(w * 0.48, h * 0.50),
      Offset(w * 0.55, h * 0.38),
      Offset(w * 0.68, h * 0.40),
      Offset(w * 0.78, h * 0.52),
      Offset(w * 0.75, h * 0.65),
      Offset(w * 0.55, h * 0.62),
      Offset(w * 0.45, h * 0.62),
    ], const Color(0xFF00005A));

    _piece(canvas, fill, lead, [
      Offset(w * 0.78, h * 0.52),
      Offset(w, h * 0.48),
      Offset(w, h * 0.60),
      Offset(w * 0.75, h * 0.65),
    ], const Color(0xFFB8860B));

    _piece(canvas, fill, lead, [
      Offset(w * 0.25, h * 0.83),
      Offset(w * 0.48, h * 0.79),
      Offset(w * 0.46, h),
      Offset(w * 0.22, h),
    ], const Color(0xFFB8860B));

    _piece(canvas, fill, lead, [
      Offset(w * 0.48, h * 0.79),
      Offset(w * 0.72, h * 0.82),
      Offset(w, h * 0.78),
      Offset(w, h),
      Offset(w * 0.46, h),
    ], const Color(0xFF8B0000));

    // cathedral silhouette
    final cathedralPath = Path();
    cathedralPath.moveTo(w * 0.04, h * 0.22);
    cathedralPath.lineTo(w * 0.04, h * 0.10);
    cathedralPath.lineTo(w * 0.06, h * 0.06);
    cathedralPath.lineTo(w * 0.08, h * 0.10);
    cathedralPath.lineTo(w * 0.08, h * 0.07);
    cathedralPath.lineTo(w * 0.10, h * 0.04);
    cathedralPath.lineTo(w * 0.12, h * 0.07);
    cathedralPath.lineTo(w * 0.12, h * 0.10);
    cathedralPath.lineTo(w * 0.14, h * 0.10);
    cathedralPath.lineTo(w * 0.14, h * 0.22);
    cathedralPath.close();
    canvas.drawPath(
      cathedralPath,
      Paint()..color = const Color(0xFF2A0000).withValues(alpha: 0.7),
    );

    // backlit glow
    final glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.1, -0.1),
        radius: 1.0,
        colors: [
          Colors.white.withValues(alpha: 0.14),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), glow);

    // edge vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.35),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), vignette);
  }

  void _piece(Canvas canvas, Paint fill, Paint lead,
      List<Offset> pts, Color color) {
    if (pts.length < 3) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var p in pts.skip(1)) path.lineTo(p.dx, p.dy);
    path.close();
    fill.color = color.withValues(alpha: 0.88);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, lead);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}