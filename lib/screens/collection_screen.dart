import 'package:flutter/material.dart';
import 'package:frames_app/models/door_model.dart';
import 'artist_card_screen.dart';

class CollectionScreen extends StatefulWidget {
  final List<Door> doors;
  final List<String> foundDoorIds;

  const CollectionScreen({
    super.key,
    required this.doors,
    required this.foundDoorIds,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Map<String, List<Door>> get _doorsByNeighbourhood {
    final Map<String, List<Door>> grouped = {};
    for (final door in widget.doors) {
      grouped.putIfAbsent(door.neighbourhood, () => []).add(door);
    }
    return grouped;
  }

  List<String> get _neighbourhoods => _doorsByNeighbourhood.keys.toList();

  Color _neighbourhoodColour(String hood) {
    switch (hood) {
      case 'City Centre':
        return const Color(0xFF8B0000);
      case 'Ropewalks':
        return const Color(0xFF6B75D6);
      case 'Baltic Triangle':
        return const Color(0xFF005000);
      case 'Waterfront':
        return const Color(0xFF00008B);
      default:
        return const Color(0xFF8B4A10);
    }
  }

  void _showCompletionDialog(String hood, Color colour) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1208),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colour, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: colour.withValues(alpha: 0.4),
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
                Icon(Icons.emoji_events,
                    color: const Color(0xFFE8C060), size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Neighbourhood Complete!',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8C060),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ve found all doors in $hood!',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA08040),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colour,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Amazing!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
  }

  String _getDoorHint(String doorId) {
    switch (doorId) {
      case 'door_001':
        return 'A grand entrance on a street that sounds like a chapel in white...';
      case 'door_002':
        return 'Climb the hill to find a door that watches over the rooftops...';
      case 'door_003':
        return 'Where merchants once traded, a door faces the river...';
      case 'door_004':
        return 'On the boldest street in Liverpool, art lives behind this door...';
      case 'door_005':
        return 'A knightly entrance on a street fit for a crusade...';
      case 'door_006':
        return 'Two streets share the same name — find the one that climbs...';
      case 'door_007':
        return 'Named for a holy man, this street hides its secrets well...';
      case 'door_008':
        return 'In the triangle where creatives gather, a door waits in Catherine\'s name...';
      case 'door_009':
        return 'Where ships once docked and prayers were said, a chapel door remains...';
      default:
        return 'Walk the streets of Liverpool to discover this hidden door...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1208),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              color: const Color(0xFF2A1A08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Collection',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE8C060),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.foundDoorIds.length} / ${widget.doors.length} doors',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFA08040),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _neighbourhoods.asMap().entries.map((entry) {
                        final i = entry.key;
                        final hood = entry.value;
                        final isActive = _currentPage == i;
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8, bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? _neighbourhoodColour(hood)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isActive
                                    ? _neighbourhoodColour(hood)
                                    : const Color(0xFF4A3018),
                              ),
                            ),
                            child: Text(
                              hood,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF7A6040),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _neighbourhoods.length,
                itemBuilder: (context, index) {
                  final hood = _neighbourhoods[index];
                  final doors = _doorsByNeighbourhood[hood] ?? [];
                  final foundCount = doors
                      .where((d) => widget.foundDoorIds.contains(d.id))
                      .length;
                  return _buildPage(hood, doors, foundCount);
                },
              ),
            ),

            Container(
              color: const Color(0xFF1A1208),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _neighbourhoods.asMap().entries.map((entry) {
                  return Container(
                    width: _currentPage == entry.key ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _currentPage == entry.key
                          ? const Color(0xFFE8C060)
                          : const Color(0xFF4A3018),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(String hood, List<Door> doors, int foundCount) {
    final colour = _neighbourhoodColour(hood);

    if (foundCount == doors.length && doors.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCompletionDialog(hood, colour);
      });
    }

    return Container(
      color: const Color(0xFF1A1208),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colour,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  hood,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE8C060),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    if (foundCount == doors.length && doors.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8C060),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'COMPLETE',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2A1A08),
                          ),
                        ),
                      ),
                    Text(
                      '$foundCount / ${doors.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFA08040),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: doors.isEmpty ? 0 : foundCount / doors.length,
                backgroundColor: const Color(0xFF2A1A08),
                valueColor: AlwaysStoppedAnimation<Color>(colour),
                minHeight: 4,
              ),
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.65,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: doors.length,
              itemBuilder: (context, index) {
                final door = doors[index];
                final isFound = widget.foundDoorIds.contains(door.id);
                return _buildDoorSticker(door, isFound, colour);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoorSticker(Door door, bool isFound, Color colour) {
    return GestureDetector(
      onTap: isFound
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArtistCardScreen(door: door),
                ),
              );
            }
          : () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF2A1A08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF4A3018)),
                  ),
                  title: const Text(
                    'Hidden Door',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      color: Color(0xFFE8C060),
                      fontSize: 16,
                    ),
                  ),
                  content: Text(
                    _getDoorHint(door.id),
                    style: const TextStyle(
                      color: Color(0xFFA08040),
                      fontSize: 12,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Got it',
                        style: TextStyle(color: Color(0xFFE8C060)),
                      ),
                    ),
                  ],
                ),
              );
            },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: isFound
                    ? [
                        BoxShadow(
                          color: colour.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CustomPaint(
                  painter: DoorStickerPainter(
                    isFound: isFound,
                    colour: colour,
                    doorId: door.id,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            door.street,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: isFound
                  ? const Color(0xFFE8C060)
                  : const Color(0xFF4A3018),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            isFound ? '✓ found' : '?',
            style: TextStyle(
              fontSize: 8,
              color: isFound
                  ? const Color(0xFF5A8A3A)
                  : const Color(0xFF3A2808),
            ),
          ),
        ],
      ),
    );
  }
}

class DoorStickerPainter extends CustomPainter {
  final bool isFound;
  final Color colour;
  final String doorId;

  DoorStickerPainter({
    required this.isFound,
    required this.colour,
    required this.doorId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgColour = isFound ? colour : const Color(0xFF2A1A08);
    final borderColour = isFound ? colour : const Color(0xFF3A2808);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(4),
      ),
      Paint()..color = bgColour.withValues(alpha: isFound ? 0.9 : 0.5),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(4),
      ),
      Paint()
        ..color = borderColour
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawLine(
      Offset(w / 2, 0),
      Offset(w / 2, h),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..strokeWidth = 1,
    );

    if (isFound) {
      _drawPanel(canvas, Rect.fromLTWH(4, 6, w / 2 - 6, h * 0.35), colour);
      _drawPanel(
          canvas, Rect.fromLTWH(w / 2 + 2, 6, w / 2 - 6, h * 0.35), colour);
      _drawPanel(
          canvas,
          Rect.fromLTWH(4, h * 0.35 + 8, w / 2 - 6, h * 0.35),
          colour);
      _drawPanel(
          canvas,
          Rect.fromLTWH(w / 2 + 2, h * 0.35 + 8, w / 2 - 6, h * 0.35),
          colour);

      canvas.drawCircle(
        Offset(w / 2 - 4, h * 0.76),
        5,
        Paint()
          ..color = const Color(0xFFE8C060)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(w / 2 - 4, h * 0.76),
        5,
        Paint()
          ..color = const Color(0xFF2A1800)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      canvas.drawCircle(
        Offset(w - 8, 8),
        7,
        Paint()..color = const Color(0xFF5A8A3A),
      );
      final tickPath = Path();
      tickPath.moveTo(w - 12, 8);
      tickPath.lineTo(w - 9, 11);
      tickPath.lineTo(w - 4, 5);
      canvas.drawPath(
        tickPath,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    } else {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '?',
          style: TextStyle(
            color: Color(0xFF3A2808),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (w - textPainter.width) / 2,
          (h - textPainter.height) / 2,
        ),
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2, 2, w - 4, h - 4),
          const Radius.circular(3),
        ),
        Paint()
          ..color = const Color(0xFF3A2808)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _drawPanel(Canvas canvas, Rect rect, Color colour) {
    canvas.drawRect(
      rect,
      Paint()..color = colour.withValues(alpha: 0.3),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant DoorStickerPainter oldDelegate) =>
      oldDelegate.isFound != isFound;
}