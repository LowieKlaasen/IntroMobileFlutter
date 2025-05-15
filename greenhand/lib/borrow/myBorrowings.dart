import 'package:flutter/material.dart';

class MyBorrowings extends StatelessWidget {
  const MyBorrowings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Borrowings"),
        backgroundColor: const Color(0xFF636B2F),
      ),
      body: const Center(
        child: Text(
          "This is the My Borrowings page.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
