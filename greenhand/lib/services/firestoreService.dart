import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<Map<String, String>> fetchUserName(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .where('auth_id', isEqualTo: userId)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return {'firstName': doc['firstName'], 'lastName': doc['lastName']};
      } else {
        return {};
      }
    } catch (error) {
      print("Error fetching user");
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> fetchItemsByCategory(
    String category,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('devices')
              .where('category', isEqualTo: category)
              .get();

      return await Future.wait(
        snapshot.docs.map((doc) async {
          final userName = await fetchUserName(doc['userId']);

          return {
            'name': doc['name'],
            'description': doc['description'],
            'price': doc['price'],
            'startDate': doc['startDate'],
            'endDate': doc['endDate'],
            'imageUrl': doc['imageUrl'],
            'latitude': doc['latitude'] ?? 0.0, // Default to 0.0 if null
            'longitude': doc['longitude'] ?? 0.0, // Default to 0.0 if null
            'user_firstName': userName['firstName'] ?? '',
            'user_lastName': userName['lastName'] ?? '',
            'id': doc.id,
            'userId': doc['userId'],
          };
        }).toList(),
      );
    } catch (error) {
      print('Error fetching items by category: $error');
      return [];
    }
  }

  Future<XFile> base64ToImage(String base64) async {
    try {
      // Decode the Base64 string into bytes
      Uint8List bytes = base64Decode(base64);

      // Get the temporary directory to store the image
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/decoded_image.png';

      // Write the bytes to a file
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Return the file as an XFile
      return XFile(filePath);
    } catch (e) {
      print("Error converting Base64 to image: $e");
      throw Exception("Failed to convert Base64 to image");
    }
  }

  Future<List<Object>> fetchItemsByUserId(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('devices')
              .where('userId', isEqualTo: userId)
              .get();

      return snapshot.docs.map((doc) async {
        return {
          'name': doc['name'],
          'description': doc['description'],
          'category': doc['category'],
          'price': doc['price'],
          'startDate': doc['startDate'],
          'endDate': doc['endDate'],
          'imageUrl': doc['imageUrl'],
          // 'imageUrl': await base64ToImage(doc['imageUrl']),
        };
      }).toList();
    } catch (error) {
      print("Error fetching items by userId: $error");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchListingsWithLocation() async {
    try {
      final snapshot = await _firestore.collection('devices').get();
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'description': doc['description'],
          'category': doc['category'],
          'price': doc['price'],
          'startDate': doc['startDate'],
          'endDate': doc['endDate'],
          'imageUrl': doc['imageUrl'],
          'latitude': doc['latitude'],
          'longitude': doc['longitude'],
          'userId': doc['userId'],
        };
      }).toList();
    } catch (error) {
      print("Error fetching listings with location: $error");
      return [];
    }
  }

  Future<void> addBorrow({
    required String deviceId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await _firestore.collection('borrowings').add({
        'deviceId': deviceId,
        'userId': userId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      print("Error adding borrow information: $error");
      throw Exception("Failed to add borrow information");
    }
  }
}
