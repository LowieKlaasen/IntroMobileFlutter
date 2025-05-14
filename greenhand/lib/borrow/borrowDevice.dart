import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestoreService.dart';

class BorrowDevice extends StatefulWidget {
  final Map<String, dynamic> device;

  const BorrowDevice({super.key, required this.device});

  @override
  State<BorrowDevice> createState() => _BorrowDeviceState();
}

class _BorrowDeviceState extends State<BorrowDevice> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime deviceStartDate = DateTime.parse(widget.device['startDate']);
    final DateTime deviceEndDate = DateTime.parse(widget.device['endDate']);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: deviceStartDate,
      lastDate: deviceEndDate,
    );

    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _confirmBorrow() async {
    if (_startDate != null && _endDate != null) {
      try {
        print("Device ID: ${widget.device['id']}");
        print("User ID: ${widget.device['userId']}");

        await _firestoreService.addBorrow(
          deviceId: widget.device['id'], // Check if this is null
          userId: widget.device['userId'], // Check if this is null
          startDate: _startDate!,
          endDate: _endDate!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Device borrowed successfully!")),
        );

        Navigator.pop(context); // Go back to the previous screen
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to borrow device: $error")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both dates.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Borrow Device"),
        backgroundColor: const Color(0xFF636B2F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Borrowing: ${widget.device['name']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Select Borrowing Dates",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _startDate != null
                            ? DateFormat('MMM dd, yyyy').format(_startDate!)
                            : "Start Date",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _endDate != null
                            ? DateFormat('MMM dd, yyyy').format(_endDate!)
                            : "End Date",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmBorrow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF636B2F),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Confirm Borrowing",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
