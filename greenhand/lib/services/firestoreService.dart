import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const platform = MethodChannel('mega_channel');

  Future<List<String>> fetchCategories() async {
    try {
      final categories = await _firestore.collection('categories').get();

      return categories.docs.map((doc) => doc['name'] as String).toList();
    } catch (error) {
      print('Error fetching categories: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategoriesWithIcons() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) {
        return {'name': doc['name'], 'icon': doc['icon']};
      }).toList();
    } catch (error) {
      print("Error getting categories with their icons: $error");
      return [];
    }
  }

  Future<void> addDevice(Map<String, dynamic> device) async {
    try {
      await _firestore.collection('devices').add(device);
    } catch (error) {
      throw Exception("Error adding device: $error");
    }
  }

  Future<String?> uploadImage(XFile image) async {
    try {
      final storageRef = _storage.ref().child(
        'device_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}',
      );
      final uploadTask = await storageRef.putFile(File(image.path));
      return await uploadTask.ref.getDownloadURL();
    } catch (error) {
      print("Error uploading image: $error");
      return null;
    }
  }
}
