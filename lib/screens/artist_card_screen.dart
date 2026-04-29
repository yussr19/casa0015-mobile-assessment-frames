import 'package:flutter/material.dart';
import 'package:frames_app/models/door_model.dart';
import 'package:frames_app/models/artist_model.dart';
import 'package:frames_app/services/firestore_service.dart';

class ArtistCardScreen extends StatefulWidget {
  final Door door;

  const ArtistCardScreen({super.key, required this.door});

  @override
  State<ArtistCardScreen> createState() => _ArtistCardScreenState();
}

class _ArtistCardScreenState extends State<ArtistCardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  Artist? _artist;
  bool _isLoading = true;
  bool _artworkExpanded = false;

  final FirestoreService _firestoreService = FirestoreService();

  // colour based on door neighbourhood
  Color get _doorColour {
    switch (widget.door.neighbourhood) {
      case 'City Centre':
        return const Color(0xFF8B0000);
      case 'Ropewalks':
        return const Color(0xFF00006B);
      case 'Baltic Triangle':
        return const Color(0xFF005000);
      case 'Waterfront':
        return const Color(0xFF00008B);
      default:
        return const Color(0xFF8B4A10);
    }
  }

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _loadArtist();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _loadArtist() async {
    if (widget.door.artistId.isNotEmpty) {
      final artist = await _firestoreService.getArtist(widget.door.artistId);
      setState(() {
        _artist = artist;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0804),
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1A08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFE8C060),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${widget.door.street} · Artist Card',
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 14,
                        color: Color(0xFFE8C060),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1A08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.door.neighbourhood,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFFA08040),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // card in centre
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Color(0xFFE8C060),
                      )
                    : GestureDetector(
                        onTap: _flipCard,
                        child: AnimatedBuilder(
                          animation: _flipAnimation,
                          builder: (context, child) {
                            final angle = _flipAnimation.value * 3.14159;
                            final isShowingFront = angle < 1.5708;

                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(angle),
                              alignment: Alignment.center,
                              child: isShowingFront
                                  ? _buildCardFront()
                                  : Transform(
                                      transform: Matrix4.identity()
                                        ..rotateY(3.14159),
                                      alignment: Alignment.center,
                                      child: _buildCardBack(),
                                    ),
                            );
                          },
                        ),
                      ),
              ),
            ),

            // tap hint
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                _isFlipped ? 'tap card to see door' : 'tap card to reveal artist',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6A5030),
                  letterSpacing: 1,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),

      // artwork fullscreen overlay
      extendBody: true,
    );
  }

  Widget _buildCardFront() {
    return Container(
      width: 240,
      height: 340,
      decoration: BoxDecoration(
        color: _doorColour,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _doorColour.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // door design
          Positioned.fill(
            child: CustomPaint(
              painter: CardDoorPainter(colour: _doorColour),
            ),
          ),

          // street name at bottom
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.door.street.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE8C060),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          // card number
          Positioned(
            top: 10,
            left: 12,
            child: Text(
              '#${widget.door.id.replaceAll('door_', '')}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),

          // found badge
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF5A8A3A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: 240,
      height: 340,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // coloured header
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            decoration: BoxDecoration(
              color: _doorColour,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Frames · ${widget.door.neighbourhood}',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _artist?.name.isNotEmpty == true
                      ? _artist!.name
                      : 'Artist TBC',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.door.street} · Card #${widget.door.id.replaceAll('door_', '')}',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // bio
                  Text(
                    _artist?.bio.isNotEmpty == true
                        ? _artist!.bio
                        : 'Artist biography coming soon.',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF3A2A18),
                      height: 1.5,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),
                  Container(
                      height: 0.5,
                      color: const Color(0xFFDDD4BC)),
                  const SizedBox(height: 10),

                  // artwork thumbnail
                  GestureDetector(
                    onTap: () {
                      if (_artist?.artworkUrl.isNotEmpty == true) {
                        setState(() => _artworkExpanded = true);
                      }
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: _doorColour.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFDDD4BC),
                        ),
                      ),
                      child: _artist?.artworkUrl.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                _artist!.artworkUrl,
                                fit: BoxFit.contain,
                                alignment: Alignment.topCenter,
                                width: double.infinity,
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    color: _doorColour.withValues(alpha: 0.4),
                                    size: 28,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Artwork coming soon',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: _doorColour.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  Container(
                      height: 0.5,
                      color: const Color(0xFFDDD4BC)),
                  const SizedBox(height: 8),

                  // style
                  if (_artist?.style.isNotEmpty == true)
                    Text(
                      _artist!.style,
                      style: TextStyle(
                        fontSize: 9,
                        color: _doorColour,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF2A1A08),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${widget.door.id.replaceAll('door_', '')} of 9',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFFA08040),
                  ),
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      Icons.star,
                      size: 10,
                      color: i < 3
                          ? const Color(0xFFE8C040)
                          : const Color(0xFF4A3018),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// paints a door on the card front
class CardDoorPainter extends CustomPainter {
  final Color colour;

  CardDoorPainter({required this.colour});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // centre split
    canvas.drawLine(
      Offset(w / 2, 0),
      Offset(w / 2, h),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..strokeWidth = 2,
    );

    // upper panels
    _drawPanel(canvas, Rect.fromLTWH(12, 20, w / 2 - 18, h * 0.32), colour);
    _drawPanel(
        canvas, Rect.fromLTWH(w / 2 + 6, 20, w / 2 - 18, h * 0.32), colour);

    // lower panels
    _drawPanel(
        canvas,
        Rect.fromLTWH(12, h * 0.32 + 28, w / 2 - 18, h * 0.28),
        colour);
    _drawPanel(
        canvas,
        Rect.fromLTWH(w / 2 + 6, h * 0.32 + 28, w / 2 - 18, h * 0.28),
        colour);

    // knocker
    final cx = w / 2 - 5;
    final cy = h * 0.68;
    canvas.drawCircle(
      Offset(cx, cy),
      14,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: const [
            Color(0xFFE8C040),
            Color(0xFFC09010),
            Color(0xFF8B6200),
          ],
        ).createShader(Rect.fromCenter(
          center: Offset(cx, cy),
          width: 28,
          height: 28,
        )),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      14,
      Paint()
        ..color = const Color(0xFF2A1800)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      6,
      Paint()..color = const Color(0xFF2A1800),
    );
  }

  void _drawPanel(Canvas canvas, Rect rect, Color colour) {
    canvas.drawRect(
      rect,
      Paint()..color = colour.withValues(alpha: 0.35),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}