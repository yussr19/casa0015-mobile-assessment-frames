// artist linked to a door - gets revealed when user scans the qr code
class Artist {
  final String id;
  final String name;
  final String bio;
  final String style;
  final int activeFrom;
  final String neighbourhood;
  final String artworkUrl;
  final String doorId;

  Artist({
    required this.id,
    required this.name,
    required this.bio,
    required this.style,
    required this.activeFrom,
    required this.neighbourhood,
    required this.artworkUrl,
    required this.doorId,
  });

  // convert firestore doc to artist object
  factory Artist.fromFirestore(Map<String, dynamic> data) {
    return Artist(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      bio: data['bio'] ?? '',
      style: data['style'] ?? '',
      activeFrom: (data['activeFrom'] ?? 0).toInt(),
      neighbourhood: data['neighbourhood'] ?? '',
      artworkUrl: data['artworkUrl'] ?? '',
      doorId: data['doorId'] ?? '',
    );
  }
}
