import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/door_model.dart';
import '../models/artist_model.dart';

// handles all the firebase/firestore calls
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // fetch all doors from firestore
  Future<List<Door>> getDoors() async {
    try {
      final snapshot = await _db.collection('doors').get();
      return snapshot.docs
          .map((doc) => Door.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('error loading doors: $e');
      return [];
    }
  }

  // get a specific artist by their id
  Future<Artist?> getArtist(String artistId) async {
    try {
      final doc = await _db.collection('artists').doc(artistId).get();
      if (doc.exists) {
        return Artist.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      print('error loading artist: $e');
      return null;
    }
  }

  // called when user successfully scans a door qr code
  Future<void> markDoorFound(String userId, String doorId) async {
    try {
      await _db.collection('users').doc(userId).set({
        'foundDoors': FieldValue.arrayUnion([doorId]),
        'doorsFound': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('error marking door as found: $e');
    }
  }

  // get list of door ids the user has already found
  Future<List<String>> getFoundDoors(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return List<String>.from(data['foundDoors'] ?? []);
      }
      return [];
    } catch (e) {
      print('error getting found doors: $e');
      return [];
    }
  }

  // live leaderboard stream so it updates in real time
  Stream<QuerySnapshot> getLeaderboard() {
    return _db
        .collection('users')
        .orderBy('doorsFound', descending: true)
        .limit(10)
        .snapshots();
  }

  // user can nominate a new door to be added to the app
  Future<void> nominateDoor({
    required String userId,
    required String street,
    required String neighbourhood,
    required String notes,
  }) async {
    try {
      await _db.collection('nominations').add({
        'userId': userId,
        'street': street,
        'neighbourhood': neighbourhood,
        'notes': notes,
        'type': 'door',
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('error submitting nomination: $e');
    }
  }

  // user can suggest an artist to be featured
  Future<void> suggestArtist({
    required String userId,
    required String artistName,
    required String notes,
  }) async {
    try {
      await _db.collection('nominations').add({
        'userId': userId,
        'artistName': artistName,
        'notes': notes,
        'type': 'artist',
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('error submitting artist suggestion: $e');
    }
  }
}