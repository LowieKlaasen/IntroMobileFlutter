import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchCategories() async {
    try {
      final categories = await _firestore.collection('categories').get();

      return categories.docs.map((doc) => doc['name'] as String).toList();
    } catch (error) {
      print('Error fetching categories: $error');
      return [];
    }
  }
}
