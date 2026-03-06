import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place.dart';

class FirestoreService {
  final CollectionReference _placesCollection = FirebaseFirestore.instance.collection('places');

  Stream<List<Place>> getPlaces() {
    return _placesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    });
  }

  Future<void> addPlace(Map<String, dynamic> data) {
    return _placesCollection.add(data);
  }

  Future<void> updatePlace(String id, Map<String, dynamic> data) {
    return _placesCollection.doc(id).update(data);
  }

  Future<void> deletePlace(String id) {
    return _placesCollection.doc(id).delete();
  }
}
