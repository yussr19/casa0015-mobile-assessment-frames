import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frames_app/services/firestore_service.dart';
import 'package:share_plus/share_plus.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
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
                        'Progress',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE8C060),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // stats row
                  Row(
                    children: [
                      _statPill('${_foundDoorIds.length}', 'Doors Found'),
                      const SizedBox(width: 8),
                      _statPill('3', 'Areas'),
                      const SizedBox(width: 8),
                      _statPill('$_totalPoints', 'Points'),
                      const SizedBox(width: 8),
                      _statPill('3', 'Day Streak!'),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B4A10),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader('Leaderboard', 'This week'),
                          _buildLeaderboard(),
                          _sectionHeader('Friend Activity', 'See all'),
                          _buildActivityFeed(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE8C060),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 7,
                color: Color(0xFFA08040),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6A5030),
              letterSpacing: 0.08,
            ),
          ),
          Text(
            action,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF8B4A10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getLeaderboard(),
      builder: (context, snapshot) {
        final mockData = [
          {'name': 'Jamie T', 'doors': 14, 'isYou': false},
          {'name': 'You', 'doors': _foundDoorIds.length, 'isYou': true},
          {'name': 'Maya R', 'doors': 6, 'isYou': false},
          {'name': 'Sam K', 'doors': 4, 'isYou': false},
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: mockData.asMap().entries.map((entry) {
              final i = entry.key;
              final data = entry.value;
              final isYou = data['isYou'] as bool;
              final name = data['name'] as String;
              final doors = data['doors'] as int;

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isYou
                      ? const Color(0xFFFDF5E8)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isYou
                        ? const Color(0xFFD4A860)
                        : const Color(0xFFE8E0D0),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Georgia',
                          color: i == 0
                              ? const Color(0xFFE8C040)
                              : i == 1
                                  ? const Color(0xFF8B4A10)
                                  : const Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isYou
                            ? const Color(0xFFFDF0DC)
                            : const Color(0xFFE8E0D0),
                      ),
                      child: Center(
                        child: Text(
                          name.substring(0, 1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isYou
                                ? const Color(0xFF8B4A10)
                                : const Color(0xFF6A6060),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isYou ? 'You' : name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2A1A08),
                        ),
                      ),
                    ),
                    Text(
                      '$doors doors',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2A1A08),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildActivityFeed() {
    final activities = [
      {
        'name': 'Jamie T',
        'action': 'found a door on Bold Street',
        'time': '2 mins ago',
        'canShare': true,
      },
      {
        'name': 'Maya R',
        'action': 'completed the Ropewalks collection',
        'time': '1 hr ago',
        'canShare': false,
      },
      {
        'name': 'Sam K',
        'action': 'unlocked a new artist in Baltic Triangle',
        'time': '3 hrs ago',
        'canShare': true,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: activities.map((activity) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE8E0D0),
                width: 0.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8E0D0),
                  ),
                  child: Center(
                    child: Text(
                      (activity['name'] as String).substring(0, 1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A6060),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF3A2A18),
                          ),
                          children: [
                            TextSpan(
                              text: '${activity['name']} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: activity['action'] as String),
                          ],
                        ),
                      ),
                      if (activity['canShare'] == true)
                        GestureDetector(
                          onTap: () {
                            Share.share(
                              'Check out the Frames app - discovering Liverpool\'s hidden artists! ${activity['name']} just ${activity['action']}',
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF5E8),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFD4A860),
                                width: 0.5,
                              ),
                            ),
                            child: const Text(
                              'Share artist',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF8B4A10),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        activity['time'] as String,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFFA08060),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}