import 'package:flutter/material.dart';

class DeviceDetail extends StatelessWidget {
  final Map<String, dynamic> device;

  const DeviceDetail({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device['name'] ?? "Device Detail"),
        backgroundColor: Color(0xFF636B2F),
      ),
      body: Center(
        child: Text(
          "To Be Implemented",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
