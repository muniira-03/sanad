import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad_app/screens/login_selection_screen.dart';
import 'package:sanad_app/screens/student_home.dart';
import 'package:sanad_app/screens/volunteer_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay
    final user = _auth.currentUser;

    if (mounted) {
      if (user != null) {
        await _goHome(user.uid);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
        );
      }
    }
  }

  Future<void> _goHome(String uid) async {
    try {
      // ✅ Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final role = userDoc.data()?['role'];

        if (role == 'volunteer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VolunteerHome()),
          );
        } else if (role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentHome(studentId: userDoc['studentId']),
            ),
          );
        } else {
          // if no role found, go to login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
          );
        }
      } else {
        // no document found → go to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
        );
      }
    } catch (e) {
      print("Error checking user role: $e");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF64B5F6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "سـنـد",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 60,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "منصة دعم الطلاب في جامعة الملك سعود",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
