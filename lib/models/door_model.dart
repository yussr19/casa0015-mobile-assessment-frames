// model for a door location in Liverpool
class Door {
  final String id;
  final String street;
  final String neighbourhood;
  final double lat;
  final double lng;
  final String imageFile;
  final String qrValue;
  final String artistId;
  final bool isActive;
  bool isFound;

  Door({
    required this.id,
    required this.street,
    required this.neighbourhood,
    required this.lat,
    required this.lng,
    required this.imageFile,
    required this.qrValue,
    required this.artistId,
    required this.isActive,
    this.isFound = false,
  });

  // convert firestore data into a Door object
  factory Door.fromFirestore(Map<String, dynamic> data) {
    return Door(
      id: data['id'] ?? '',
      street: data['street'] ?? '',
      neighbourhood: data['neighbourhood'] ?? '',
      lat: (data['lat'] ?? 0.0).toDouble(),
      lng: (data['lng'] ?? 0.0).toDouble(),
      imageFile: data['imageFile'] ?? '',
      qrValue: data['qrValue'] ?? '',
      artistId: data['artistId'] ?? '',
      isActive: data['isActive'] as bool? ?? true,
      
    );
  }
  // rarity based on door id
int get rarity {
  switch (id) {
    case 'door_001':
    case 'door_003':
    case 'door_009':
      return 1; // common
    case 'door_002':
    case 'door_004':
    case 'door_007':
      return 2; // rare
    case 'door_005':
    case 'door_006':
    case 'door_008':
      return 3; // legendary
    default:
      return 1;
  }
}

// rarity label
String get rarityLabel {
  switch (rarity) {
    case 1: return 'Common';
    case 2: return 'Rare';
    case 3: return 'Legendary';
    default: return 'Common';
  }
}
}
