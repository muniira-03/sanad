import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad_app/screens/login_selection_screen.dart';

class StudentProfile extends StatefulWidget {
  final String studentId; // ✅ we’ll pass this from login page

  const StudentProfile({required this.studentId, super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  final firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getStudentData() async {
    try {
      final query = await firestore
          .collection('users')
          .where('studentId', isEqualTo: widget.studentId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return query.docs.first.data();
    } catch (e) {
      debugPrint('Error fetching student data: $e');
      return null;
    }
  }

  Future<void> logoutUser() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout Successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F6F8),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getStudentData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'No data found or you are not logged in.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.lightBlueAccent,
                    child: Icon(
                      Icons.person_2_outlined,
                      color: Colors.blueGrey,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Student name: ${data['name'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Student email: ${data['email'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Student ID: ${data['studentId'] ?? widget.studentId}",
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Completed sessions: 0",
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Student status: Active",
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Contact us: support@studentapp.com",
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: logoutUser,
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 22, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
