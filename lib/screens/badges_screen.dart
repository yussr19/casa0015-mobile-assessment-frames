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
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: const Color(0xFF0A0A1A),
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
      'door_002',
      'door_004',
      'door_005',
      'door_006',
      'door_007'
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

class LiverpoolCathedralPainter extends CustomPainter {
  final Color colour;
  LiverpoolCathedralPainter({required this.colour});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF020410),
        const Color(0xFF0A0A2A),
        const Color(0xFF1A0A08),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
    paint.shader = null;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.3),
          radius: 0.6,
          colors: [
            colour.withValues(alpha: 0.3),
            colour.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    final c = Paint()..color = colour.withValues(alpha: 0.9);

    canvas.drawRect(Rect.fromLTWH(w * 0.38, h * 0.2, w * 0.24, h * 0.65), c);

    final crownPath = Path();
    crownPath.moveTo(w * 0.38, h * 0.2);
    crownPath.lineTo(w * 0.40, h * 0.08);
    crownPath.lineTo(w * 0.42, h * 0.12);
    crownPath.lineTo(w * 0.44, h * 0.04);
    crownPath.lineTo(w * 0.46, h * 0.10);
    crownPath.lineTo(w * 0.48, h * 0.06);
    crownPath.lineTo(w * 0.50, h * 0.12);
    crownPath.lineTo(w * 0.52, h * 0.08);
    crownPath.lineTo(w * 0.54, h * 0.14);
    crownPath.lineTo(w * 0.56, h * 0.10);
    crownPath.lineTo(w * 0.58, h * 0.16);
    crownPath.lineTo(w * 0.62, h * 0.2);
    crownPath.close();
    canvas.drawPath(crownPath, c);

    canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.45, w * 0.23, h * 0.40), c);
    canvas.drawRect(Rect.fromLTWH(w * 0.62, h * 0.45, w * 0.23, h * 0.40), c);

    final windowPaint = Paint()..color = colour.withValues(alpha: 0.3);
    for (int i = 0; i < 3; i++) {
      final wx = w * 0.17 + i * w * 0.06;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(wx, h * 0.52, w * 0.04, h * 0.15),
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
        ),
        windowPaint,
      );
    }
    for (int i = 0; i < 3; i++) {
      final wx = w * 0.64 + i * w * 0.06;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(wx, h * 0.52, w * 0.04, h * 0.15),
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
        ),
        windowPaint,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.44, h * 0.28, w * 0.12, h * 0.18),
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
      ),
      windowPaint,
    );

    paint.color = colour.withValues(alpha: 0.4);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.85, w, h * 0.15), paint);

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    for (final star in [
      [0.1, 0.1], [0.2, 0.05], [0.8, 0.08], [0.9, 0.15],
      [0.15, 0.25], [0.85, 0.20], [0.05, 0.35], [0.95, 0.30],
    ]) {
      canvas.drawCircle(Offset(w * star[0], h * star[1]), 1.5, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LiverBuildingPainter extends CustomPainter {
  final Color colour;
  LiverBuildingPainter({required this.colour});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

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

    canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.35, w * 0.28, h * 0.40), c);
    canvas.drawRect(Rect.fromLTWH(w * 0.60, h * 0.35, w * 0.28, h * 0.40), c);
    canvas.drawRect(Rect.fromLTWH(w * 0.30, h * 0.45, w * 0.40, h * 0.30), c);
    canvas.drawRect(Rect.fromLTWH(w * 0.17, h * 0.18, w * 0.16, h * 0.18), c);
    canvas.drawRect(Rect.fromLTWH(w * 0.67, h * 0.18, w * 0.16, h * 0.18), c);

    final leftDomePath = Path();
    leftDomePath.moveTo(w * 0.17, h * 0.18);
    leftDomePath.quadraticBezierTo(w * 0.25, h * 0.04, w * 0.33, h * 0.18);
    leftDomePath.close();
    canvas.drawPath(leftDomePath, c);

    final rightDomePath = Path();
    rightDomePath.moveTo(w * 0.67, h * 0.18);
    rightDomePath.quadraticBezierTo(w * 0.75, h * 0.04, w * 0.83, h * 0.18);
    rightDomePath.close();
    canvas.drawPath(rightDomePath, c);

    final birdPaint = Paint()..color = colour;
    _drawBird(canvas, birdPaint, w * 0.25, h * 0.04, 8);
    _drawBird(canvas, birdPaint, w * 0.75, h * 0.04, 8);

    final windowPaint = Paint()..color = colour.withValues(alpha: 0.25);
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 4; col++) {
        canvas.drawRect(
          Rect.fromLTWH(
            w * 0.14 + col * w * 0.065,
            h * 0.40 + row * h * 0.09,
            w * 0.04,
            h * 0.06,
          ),
          windowPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            w * 0.62 + col * w * 0.065,
            h * 0.40 + row * h * 0.09,
            w * 0.04,
            h * 0.06,
          ),
          windowPaint,
        );
      }
    }

    canvas.drawRect(
      Rect.fromLTWH(w * 0.25, h * 0.76, w * 0.50, h * 0.08),
      Paint()..color = colour.withValues(alpha: 0.15),
    );

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    for (final star in [
      [0.05, 0.08], [0.15, 0.04], [0.85, 0.06], [0.95, 0.12],
      [0.45, 0.08], [0.55, 0.03], [0.92, 0.22],
    ]) {
      canvas.drawCircle(Offset(w * star[0], h * star[1]), 1.5, starPaint);
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