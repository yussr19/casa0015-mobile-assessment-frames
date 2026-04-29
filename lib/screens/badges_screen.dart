import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frames_app/services/firestore_service.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<String> _foundDoorIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final foundIds = await _firestoreService.getFoundDoors(userId);
    setState(() {
      _foundDoorIds = foundIds;
      _isLoading = false;
    });
  }

  bool _isNeighbourhoodComplete(List<String> doorIds) {
    return doorIds.every((id) => _foundDoorIds.contains(id));
  }

  bool get _hasLegendary => _foundDoorIds.any(
      (id) => ['door_005', 'door_006', 'door_008'].contains(id));

  bool get _hasRare => _foundDoorIds.any(
      (id) => ['door_002', 'door_004', 'door_007'].contains(id));

  int get _totalPoints {
    int points = 0;
    for (final id in _foundDoorIds) {
      if (['door_005', 'door_006', 'door_008'].contains(id)) {
        points += 50;
      } else if (['door_002', 'door_004', 'door_007'].contains(id)) {
        points += 25;
      } else {
        points += 10;
      }
    }
    return points;
  }

  Widget _buildBadgeDialog(BuildContext context, Map<String, Object> badge,
      bool unlocked, Color colour, int index) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1208),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked ? colour : const Color(0xFF3A2808),
          width: 1.5,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: colour.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (unlocked)
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Color(0xFF0A0A1A),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: CustomPaint(
                  painter: index == 0
                      ? LiverpoolCathedralPainter(colour: colour)
                      : index == 4
                          ? LiverBuildingPainter(colour: colour)
                          : GenericLandmarkPainter(colour: colour),
                  size: Size.infinite,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  badge['title'] as String,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: unlocked
                        ? const Color(0xFFE8C060)
                        : const Color(0xFF6A5030),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  unlocked
                      ? '${badge['description']}\n\nUnlocked!'
                      : '${badge['description']}\n\nKeep exploring to unlock this badge.',
                  style: const TextStyle(
                    color: Color(0xFFA08040),
                    fontSize: 12,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: unlocked ? colour : const Color(0xFF2A1A08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cityCentreDoors = ['door_001', 'door_003', 'door_009'];
    final ropewalksDoors = [
      'door_002', 'door_004', 'door_005', 'door_006', 'door_007'
    ];
    final balticDoors = ['door_008'];

    final badges = [
      {
        'title': 'First Steps',
        'description': 'Find your first door in Liverpool',
        'icon': Icons.door_front_door_outlined,
        'colour': const Color(0xFF8B4A10),
        'unlocked': _foundDoorIds.isNotEmpty,
      },
      {
        'title': 'City Centre Explorer',
        'description': 'Complete all City Centre doors',
        'icon': Icons.location_city,
        'colour': const Color(0xFF8B0000),
        'unlocked': _isNeighbourhoodComplete(cityCentreDoors),
      },
      {
        'title': 'Ropewalks Regular',
        'description': 'Complete all Ropewalks doors',
        'icon': Icons.route_outlined,
        'colour': const Color(0xFF6B75D6),
        'unlocked': _isNeighbourhoodComplete(ropewalksDoors),
      },
      {
        'title': 'Baltic Pioneer',
        'description': 'Complete all Baltic Triangle doors',
        'icon': Icons.architecture,
        'colour': const Color(0xFF005000),
        'unlocked': _isNeighbourhoodComplete(balticDoors),
      },
      {
        'title': 'Rare Find',
        'description': 'Discover a rare door',
        'icon': Icons.star_half,
        'colour': const Color(0xFFAAAAAA),
        'unlocked': _hasRare,
      },
      {
        'title': 'Legend',
        'description': 'Discover a legendary door',
        'icon': Icons.auto_awesome,
        'colour': const Color(0xFFE8C060),
        'unlocked': _hasLegendary,
      },
      {
        'title': 'Art Collector',
        'description': 'Unlock 5 artist cards',
        'icon': Icons.collections_outlined,
        'colour': const Color(0xFF3A006B),
        'unlocked': _foundDoorIds.length >= 5,
      },
      {
        'title': 'Liverpool Legend',
        'description': 'Find all 9 doors in Liverpool',
        'icon': Icons.emoji_events,
        'colour': const Color(0xFFE8C060),
        'unlocked': _foundDoorIds.length >= 9,
      },
      {
        'title': 'High Scorer',
        'description': 'Earn 100 points or more',
        'icon': Icons.bar_chart,
        'colour': const Color(0xFF8B4A10),
        'unlocked': _totalPoints >= 100,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1208),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF2A1A08),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFFE8C060),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Badges',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE8C060),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${badges.where((b) => b['unlocked'] == true).length} / ${badges.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFA08040),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1208),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$_totalPoints',
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE8C060),
                          ),
                        ),
                        const Text(
                          'total points',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFA08040),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE8C060),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(14),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: badges.length,
                      itemBuilder: (context, index) {
                        final badge = badges[index];
                        final unlocked = badge['unlocked'] as bool;
                        final colour = badge['colour'] as Color;

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: _buildBadgeDialog(
                                  context,
                                  badge,
                                  unlocked,
                                  colour,
                                  index,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: unlocked
                                  ? const Color(0xFF2A1A08)
                                  : const Color(0xFF141008),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: unlocked
                                    ? colour.withValues(alpha: 0.5)
                                    : const Color(0xFF2A1A08),
                                width: 1.5,
                              ),
                              boxShadow: unlocked
                                  ? [
                                      BoxShadow(
                                        color: colour.withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: unlocked
                                        ? colour.withValues(alpha: 0.15)
                                        : const Color(0xFF2A1A08),
                                  ),
                                  child: Icon(
                                    badge['icon'] as IconData,
                                    size: 24,
                                    color: unlocked
                                        ? colour
                                        : const Color(0xFF3A2808),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Text(
                                    badge['title'] as String,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: unlocked
                                          ? const Color(0xFFE8C060)
                                          : const Color(0xFF3A2808),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Text(
                                    unlocked ? 'Unlocked' : 'Locked',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 7,
                                      color: unlocked
                                          ? colour.withValues(alpha: 0.8)
                                          : const Color(0xFF2A1808),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Detailed Liverpool Cathedral painter
class LiverpoolCathedralPainter extends CustomPainter {
  final Color colour;
  LiverpoolCathedralPainter({required this.colour});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    // night sky gradient
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF020410),
        const Color(0xFF0A0820),
        const Color(0xFF1A0A08),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
    paint.shader = null;

    // warm glow behind cathedral
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.4),
          radius: 0.7,
          colors: [
            colour.withValues(alpha: 0.35),
            colour.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    final stonePaint = Paint()..color = const Color(0xFFD4C4A0);
    final darkPaint = Paint()..color = const Color(0xFF0A0A1A);
    final glowWindowPaint = Paint()
      ..color =colour.withValues(alpha: 0.9);
    final linePaint = Paint()
      ..color = colour.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // ground
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.88, w, h * 0.12),
      Paint()..color = colour.withValues(alpha: 0.3),
    );

    // left transept
    canvas.drawRect(
      Rect.fromLTWH(w * 0.08, h * 0.52, w * 0.18, h * 0.36),
      stonePaint,
    );

    // right transept
    canvas.drawRect(
      Rect.fromLTWH(w * 0.74, h * 0.52, w * 0.18, h * 0.36),
      stonePaint,
    );

    // main nave body
    canvas.drawRect(
      Rect.fromLTWH(w * 0.20, h * 0.58, w * 0.60, h * 0.30),
      stonePaint,
    );

    // main central tower base
    canvas.drawRect(
      Rect.fromLTWH(w * 0.33, h * 0.28, w * 0.34, h * 0.60),
      stonePaint,
    );

    // tower detail lines
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(w * 0.33, h * (0.28 + i * 0.12)),
        Offset(w * 0.67, h * (0.28 + i * 0.12)),
        linePaint,
      );
    }

    // gothic arched windows on tower
    for (int i = 0; i < 2; i++) {
      final wx = w * 0.38 + i * w * 0.14;
      // window arch
      final windowPath = Path();
      windowPath.moveTo(wx, h * 0.50);
      windowPath.lineTo(wx, h * 0.38);
      windowPath.quadraticBezierTo(
          wx + w * 0.05, h * 0.32, wx + w * 0.10, h * 0.38);
      windowPath.lineTo(wx + w * 0.10, h * 0.50);
      windowPath.close();
      canvas.drawPath(windowPath, glowWindowPaint);
      canvas.drawPath(windowPath, linePaint..color = colour.withValues(alpha: 0.6));
    }
    // rose window (circular)
       canvas.drawCircle(
          Offset(w * 0.50, h * 0.36),
         w * 0.055,
        glowWindowPaint,
        );
    // rose window spokes
    for (int i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      canvas.drawLine(
        Offset(w * 0.50, h * 0.40),
        Offset(
          w * 0.50 + w * 0.07 * (angle.toString().contains('.') ? 1 : 1) *
              0.9 * (i % 2 == 0 ? 1 : -1) * 0.5,
          h * 0.40 + w * 0.07 * 0.9 * (i < 4 ? -1 : 1) * 0.5,
        ),
        Paint()
          ..color = colour.withValues(alpha: 0.5)
          ..strokeWidth = 1,
      );
    }
    // crown battlements - cleaner version
    final battlementPaint = Paint()..color = const Color(0xFFD4C4A0);
    // base of crown
    canvas.drawRect(
      Rect.fromLTWH(w * 0.33, h * 0.20, w * 0.34, h * 0.08),
      battlementPaint,
    );
    // individual merlons (raised parts)
     // merlons and connected pinnacles drawn together
        for (int i = 0; i < 4; i++) {
        final px = w * 0.355 + i * w * 0.075;
        // merlon rectangle
        canvas.drawRect(
         Rect.fromLTWH(px, h * 0.135, w * 0.038, h * 0.065),
         battlementPaint,
           );
         // pinnacle triangle sitting directly on top of merlon
           final pinnPath = Path();
           pinnPath.moveTo(px + w * 0.019, h * 0.075);
           pinnPath.lineTo(px, h * 0.135);
           pinnPath.lineTo(px + w * 0.038, h * 0.135);
          pinnPath.close();
           canvas.drawPath(pinnPath, battlementPaint);
           }

    // left transept arched windows
    for (int i = 0; i < 2; i++) {
      final wy = h * 0.58 + i * h * 0.12;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(w * 0.10, wy, w * 0.06, h * 0.10),
          topLeft: const Radius.circular(15),
          topRight: const Radius.circular(15),
        ),
        glowWindowPaint,
      );
    }

    // right transept arched windows
    for (int i = 0; i < 2; i++) {
      final wy = h * 0.58 + i * h * 0.12;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(w * 0.84, wy, w * 0.06, h * 0.10),
          topLeft: const Radius.circular(15),
          topRight: const Radius.circular(15),
        ),
        glowWindowPaint,
      );
    }
   
    


    // nave clerestory windows
    for (int i = 0; i < 4; i++) {
      final wx = w * 0.23 + i * w * 0.13;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(wx, h * 0.62, w * 0.07, h * 0.12),
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
        ),
        glowWindowPaint,
      );
    }

    // stars
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (final star in [
      [0.05, 0.06], [0.12, 0.02], [0.88, 0.04], [0.95, 0.10],
      [0.20, 0.12], [0.80, 0.08], [0.03, 0.20], [0.97, 0.18],
      [0.50, 0.06], [0.30, 0.04], [0.70, 0.03],
    ]) {
      canvas.drawCircle(
        Offset(w * star[0], h * star[1]),
        1.2,
        starPaint,
      );
    }

    // moon
    canvas.drawCircle(
      Offset(w * 0.85, h * 0.15),
      8,
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Liver Building painter
class LiverBuildingPainter extends CustomPainter {
  final Color colour;
  LiverBuildingPainter({required this.colour});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    // night sky
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF020410),
        const Color(0xFF0A1428),
        const Color(0xFF0A1A2A),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
    paint.shader = null;

    // river mersey
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colour.withValues(alpha: 0.2),
        colour.withValues(alpha: 0.05),
      ],
    ).createShader(Rect.fromLTWH(0, h * 0.75, w, h * 0.25));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.75, w, h * 0.25), paint);
    paint.shader = null;

    // glow
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0),
          radius: 0.7,
          colors: [
            colour.withValues(alpha: 0.25),
            colour.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    final c = Paint()..color = colour.withValues(alpha: 0.85);
    final linePaint = Paint()
      ..color = colour.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // left tower body
    canvas.drawRect(Rect.fromLTWH(w * 0.10, h * 0.32, w * 0.30, h * 0.43), c);
    // right tower body
    canvas.drawRect(Rect.fromLTWH(w * 0.60, h * 0.32, w * 0.30, h * 0.43), c);
    // centre connecting block
    canvas.drawRect(Rect.fromLTWH(w * 0.28, h * 0.42, w * 0.44, h * 0.33), c);

    // tower detail lines
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(w * 0.10, h * (0.32 + i * 0.08)),
        Offset(w * 0.40, h * (0.32 + i * 0.08)),
        linePaint,
      );
      canvas.drawLine(
        Offset(w * 0.60, h * (0.32 + i * 0.08)),
        Offset(w * 0.90, h * (0.32 + i * 0.08)),
        linePaint,
      );
    }

    // left clock tower
    canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.16, w * 0.18, h * 0.17), c);
    // right clock tower
    canvas.drawRect(Rect.fromLTWH(w * 0.67, h * 0.16, w * 0.18, h * 0.17), c);

    // clock faces
    canvas.drawCircle(
      Offset(w * 0.24, h * 0.22),
      w * 0.055,
      Paint()..color = colour.withValues(alpha: 0.5),
    );
    canvas.drawCircle(
      Offset(w * 0.76, h * 0.22),
      w * 0.055,
      Paint()..color = colour.withValues(alpha: 0.5),
    );
    // clock hands
    canvas.drawLine(
      Offset(w * 0.24, h * 0.22),
      Offset(w * 0.24, h * 0.16),
      Paint()..color = const Color(0xFF0A0A1A)..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(w * 0.76, h * 0.22),
      Offset(w * 0.76, h * 0.16),
      Paint()..color = const Color(0xFF0A0A1A)..strokeWidth = 1.5,
    );

    // left dome
    final leftDomePath = Path();
    leftDomePath.moveTo(w * 0.15, h * 0.16);
    leftDomePath.quadraticBezierTo(w * 0.24, h * 0.02, w * 0.33, h * 0.16);
    leftDomePath.close();
    canvas.drawPath(leftDomePath, c);

    // right dome
    final rightDomePath = Path();
    rightDomePath.moveTo(w * 0.67, h * 0.16);
    rightDomePath.quadraticBezierTo(w * 0.76, h * 0.02, w * 0.85, h * 0.16);
    rightDomePath.close();
    canvas.drawPath(rightDomePath, c);

    // liver birds
    final birdPaint = Paint()..color = colour;
    _drawBird(canvas, birdPaint, w * 0.24, h * 0.02, 9);
    _drawBird(canvas, birdPaint, w * 0.76, h * 0.02, 9);

    // windows
    final windowPaint = Paint()..color = colour.withValues(alpha: 0.3);
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 4; col++) {
        canvas.drawRect(
          Rect.fromLTWH(
            w * 0.12 + col * w * 0.068,
            h * 0.36 + row * h * 0.09,
            w * 0.04,
            h * 0.06,
          ),
          windowPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            w * 0.62 + col * w * 0.068,
            h * 0.36 + row * h * 0.09,
            w * 0.04,
            h * 0.06,
          ),
          windowPaint,
        );
      }
    }

    // reflection in river
    canvas.drawRect(
      Rect.fromLTWH(w * 0.20, h * 0.76, w * 0.60, h * 0.06),
      Paint()..color = colour.withValues(alpha: 0.12),
    );

    // stars
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    for (final star in [
      [0.04, 0.08], [0.14, 0.04], [0.86, 0.06], [0.96, 0.12],
      [0.45, 0.07], [0.55, 0.03], [0.92, 0.22],
    ]) {
      canvas.drawCircle(
        Offset(w * star[0], h * star[1]),
        1.2,
        starPaint,
      );
    }
  }

  void _drawBird(Canvas canvas, Paint paint, double x, double y, double size) {
    final path = Path();
    path.moveTo(x, y);
    path.lineTo(x - size, y + size * 0.5);
    path.lineTo(x - size * 0.3, y + size * 0.3);
    path.lineTo(x, y + size * 0.8);
    path.lineTo(x + size * 0.3, y + size * 0.3);
    path.lineTo(x + size, y + size * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Generic landmark for other badges
class GenericLandmarkPainter extends CustomPainter {
  final Color colour;
  GenericLandmarkPainter({required this.colour});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF0A0A1A),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          colors: [
            colour.withValues(alpha: 0.3),
            colour.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.35, h * 0.2, w * 0.30, h * 0.60),
        const Radius.circular(4),
      ),
      Paint()..color = colour.withValues(alpha: 0.8),
    );
    canvas.drawCircle(
      Offset(w * 0.58, h * 0.52),
      w * 0.02,
      Paint()..color = const Color(0xFF1A1208),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}