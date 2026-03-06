import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  Place({
    required this.id, required this.name, required this.imageUrl, 
    required this.shortDesc, required this.longDesc, 
    this.category = 'Tất cả', this.lat = 21.0285, this.lng = 105.8542, this.rating = 4.5
  });
  final String id, name, imageUrl, shortDesc, longDesc, category;
  final double lat, lng, rating;

  factory Place.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      shortDesc: data['shortDesc'] ?? '',
      longDesc: data['longDesc'] ?? '',
      category: data['category'] ?? 'Tất cả',
      lat: (data['lat'] ?? 21.0285).toDouble(),
      lng: (data['lng'] ?? 105.8542).toDouble(),
      rating: (data['rating'] ?? 4.5).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name, 
    'imageUrl': imageUrl, 
    'shortDesc': shortDesc, 
    'longDesc': longDesc, 
    'category': category,
    'lat': lat,
    'lng': lng,
    'rating': rating,
  };
}
