import 'package:flutter/material.dart';

class SearchDashboard extends StatelessWidget {
  const SearchDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Dashboard"),
        backgroundColor: const Color(0xFF636B2F),
      ),
      body: const Center(
        child: Text(
          "Search Dashboard Placeholder",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }
}
