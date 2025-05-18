import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestoreService.dart';

class MyBorrowings extends StatefulWidget {
  const MyBorrowings({super.key});

  @override
  State<MyBorrowings> createState() => _MyBorrowingsState();
}

class _MyBorrowingsState extends State<MyBorrowings> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> _borrowingsFuture;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    _borrowingsFuture =
        userId != null
            ? _firestoreService.fetchBorrowingsByUserId(userId)
            : Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Borrowings"),
        backgroundColor: const Color(0xFF636B2F),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _borrowingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "You have no borrowings.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          final borrowings = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: GridView.builder(
              itemCount: borrowings.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final borrowing = borrowings[index];
                final device = borrowing['device'] ?? {};
                final imageBase64 = device['imageUrl'];
                final imageWidget =
                    imageBase64 != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(imageBase64),
                            width: double.infinity,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                          ),
                        )
                        : Container(
                          height: 90,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                final startDate = borrowing['startDate'];
                String dateLabel = '';
                try {
                  dateLabel = DateFormat(
                    'MMM dd',
                  ).format(DateTime.parse(startDate));
                } catch (_) {}

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageWidget,
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 8,
                        ),
                        child: Text(
                          device['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF636B2F),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                dateLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 8),
                        child: Text(
                          "${device['user_firstName'] ?? ''} ${device['user_lastName'] ?? ''}"
                              .trim(),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
