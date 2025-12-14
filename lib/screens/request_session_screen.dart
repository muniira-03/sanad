import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestSessionScreen extends StatefulWidget {
  final String studentId;

  const RequestSessionScreen({required this.studentId, super.key});

  @override
  State<RequestSessionScreen> createState() => _RequestSessionScreenState();
}

class _RequestSessionScreenState extends State<RequestSessionScreen> {
  final _majorCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  TimeOfDay? _selectedTime;

  final firestore = FirebaseFirestore.instance;

  /// 🔥 Request session and save to Firestore
  Future<void> requestSession() async {
    if (_majorCtrl.text.isEmpty ||
        _subjectCtrl.text.isEmpty ||
        _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    final timeFormatted =
        "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

    try {
      await firestore.collection('sessionRequests').add({
        'studentId': widget.studentId,
        'major': _majorCtrl.text,
        'subject': _subjectCtrl.text,
        'preferredTime': timeFormatted,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session request submitted successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      _majorCtrl.clear();
      _subjectCtrl.clear();
      setState(() => _selectedTime = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error submitting request: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 🕒 Pick a time
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F6F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Text(
                  "Request Session",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 40),

                // Major field
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enter your major",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _majorCtrl,
                  decoration: const InputDecoration(
                    fillColor: Color(0xffD9D9D9),
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 30),

                // Subject field
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enter the subject",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(
                    fillColor: Color(0xffD9D9D9),
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 40),

                // Time Picker
                GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffD9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTime == null
                              ? "Select preferred time"
                              : "Time: ${_selectedTime!.format(context)}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const Icon(Icons.access_time, size: 28),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: requestSession,
                    child: const Text(
                      "Request Session",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
