import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frames_app/services/firestore_service.dart';
import 'package:frames_app/screens/badges_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<String> _foundDoorIds = [];
  bool _isLoading = true;

  // nomination form controllers
  final _streetController = TextEditingController();
  final _neighbourhoodController = TextEditingController();
  final _notesController = TextEditingController();
  final _artistNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _neighbourhoodController.dispose();
    _notesController.dispose();
    _artistNameController.dispose();
    super.dispose();
  }

  void _loadData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final foundIds = await _firestoreService.getFoundDoors(userId);
    setState(() {
      _foundDoorIds = foundIds;
      _isLoading = false;
    });
  }

  void _showNominateDoorSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2A1A08),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nominate a Door',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  color: Color(0xFFE8C060),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Know a door in Liverpool that deserves to be in Frames?',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFA08040),
                ),
              ),
              const SizedBox(height: 16),
              _inputField(_streetController, 'Street name'),
              const SizedBox(height: 10),
              _inputField(_neighbourhoodController, 'Neighbourhood'),
              const SizedBox(height: 10),
              _inputField(_notesController, 'Any notes about the door', maxLines: 3),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                    await _firestoreService.nominateDoor(
                      userId: userId,
                      street: _streetController.text,
                      neighbourhood: _neighbourhoodController.text,
                      notes: _notesController.text,
                    );
                    _streetController.clear();
                    _neighbourhoodController.clear();
                    _notesController.clear();
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Door nominated! Thanks for contributing.'),
                          backgroundColor: Color(0xFF5A8A3A),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4A10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Submit Nomination',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSuggestArtistSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2A1A08),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Suggest an Artist',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  color: Color(0xFFE8C060),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Know a Liverpool artist who should be featured?',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFA08040),
                ),
              ),
              const SizedBox(height: 16),
              _inputField(_artistNameController, 'Artist name'),
              const SizedBox(height: 10),
              _inputField(_notesController, 'Tell us about them', maxLines: 3),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                    await _firestoreService.suggestArtist(
                      userId: userId,
                      artistName: _artistNameController.text,
                      notes: _notesController.text,
                    );
                    _artistNameController.clear();
                    _notesController.clear();
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Artist suggested! Thanks for contributing.'),
                          backgroundColor: Color(0xFF5A8A3A),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4A10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Submit Suggestion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _inputField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6A5030), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1A0E04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A2808)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A2808)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8B4A10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Column(
          children: [
            // profile hero
            Container(
              color: const Color(0xFF2A1A08),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                        'Profile',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE8C060),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8B4A10),
                      border: Border.all(
                        color: const Color(0xFFE8C060),
                        width: 2.5,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Y',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE8C060),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explorer',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '@frames_user',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _heroStat('${_foundDoorIds.length}', 'Doors'),
                      _heroDivider(),
                      _heroStat('#1', 'Rank'),
                      _heroDivider(),
                      _heroStat('3', 'Areas'),
                      _heroDivider(),
                      _heroStat(
                          '${_foundDoorIds.length > 0 ? 1 : 0}', 'Artists'),
                    ],
                  ),
                ],
              ),
            ),

            // scrollable body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // nominate section
                    _sectionLabel('Nominate'),
                    Container(
                      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1A08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Know a great door or artist?',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14,
                              color: Color(0xFFE8C060),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Help grow the Frames community by nominating doors and artists.',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFA08040),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _showNominateDoorSheet,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B4A10),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Nominate Door',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _showSuggestArtistSheet,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF4A3018),
                                      ),
                                    ),
                                    child: const Text(
                                      'Suggest Artist',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFA08040),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // settings
                    _sectionLabel('Settings'),
                    _settingsRow('Edit Profile', Icons.person_outline),
                    _settingsRow('Friends & Privacy', Icons.lock_outline),
                    _settingsRow('Notifications', Icons.notifications_none),
                    _settingsRow('About Frames', Icons.info_outline),
                    _settingsRow('Badges & Achievements', Icons.emoji_events_outlined, onTap: () {
                                 Navigator.push(
                                   context,
                             MaterialPageRoute(builder: (_) => const BadgesScreen()),
                                    );
                                    }),
                    _settingsRow('Sign Out', Icons.logout,
                    isDestructive: true, onTap: () async {
                      await FirebaseAuth.instance.signOut();
                    if (mounted) {
                     Navigator.of(context).pushNamedAndRemoveUntil(
                     '/login',
                      (route) => false,
                        );
                           }
                        }),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE8C060),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Color(0xFFA08040),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _heroDivider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF4A3018),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6A5030),
          letterSpacing: 0.08,
        ),
      ),
    );
  }

  Widget _settingsRow(String title, IconData icon,
      {bool isDestructive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE8E0D0),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDestructive
                  ? const Color(0xFFC03030)
                  : const Color(0xFF6A5030),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: isDestructive
                    ? const Color(0xFFC03030)
                    : const Color(0xFF2A1A08),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: const Color(0xFFCCC4B0),
            ),
          ],
        ),
      ),
    );
  }
}