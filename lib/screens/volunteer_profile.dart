import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad_app/screens/login_selection_screen.dart';

class VolunteerProfile extends StatefulWidget {
  VolunteerProfile({super.key});

  @override
  State<VolunteerProfile> createState() => _VolunteerProfileState();
}

class _VolunteerProfileState extends State<VolunteerProfile> {
  final auth = FirebaseAuth.instance;

  final firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getVolunteerData() async {
    final user = auth.currentUser;
    if (user == null) return null;

    final doc = await firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<void> logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
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
        future: getVolunteerData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const CircleAvatar(
                  radius: 50,
                  child: Icon(
                    Icons.person_2_outlined,
                    color: Colors.blueGrey,
                    size: 80,
                  ),
                  backgroundColor: Colors.lightBlueAccent,
                ),
                const SizedBox(height: 24),
                Text(
                  "Volunteer name: ${data['name'] ?? 'N/A'}",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 32),
                Text(
                  "Volunteer email: ${data['email'] ?? 'N/A'}",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 32),
                Text(
                  "Volunteer ID: ${auth.currentUser?.uid.substring(0, 6)}",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Completed sessions: 0",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Volunteer status: Active",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Contact us: support@volunteerapp.com",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: logoutUser,
                  child: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 24, color: Colors.red),
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }
}
