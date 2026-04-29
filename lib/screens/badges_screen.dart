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

  // check if neighbourhood is complete
  bool _isNeighbourhoodComplete(List<String> doorIds) {
    return doorIds.every((id) => _foundDoorIds.contains(id));
  }

  // check if user has found a legendary door
  bool get _hasLegendary => _foundDoorIds.any(
      (id) => ['door_005', 'door_006', 'door_008'].contains(id));

  // check if user has found a rare door
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

  @override
  Widget build(BuildContext context) {
    final cityCentreDoors = ['door_001', 'door_003', 'door_009'];
    final ropewalksDoors = ['door_002', 'door_004', 'door_005', 'door_006', 'door_007'];
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
            // header
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
                  // points total
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

            // badges grid
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

                        return Container(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
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