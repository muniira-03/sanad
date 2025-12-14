import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad_app/screens/login_screen.dart';
import 'volunteer_home.dart';
import 'student_home.dart';

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({required this.role, super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController(); // used for email or studentId
  final passCtrl = TextEditingController();

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  Future<void> signUp() async {
    setState(() => isLoading = true);

    try {
      // ✅ Volunteer flow (Firebase Auth)
      if (widget.role.toLowerCase() == 'volunteer') {
        final userCred = await auth.createUserWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );

        await firestore.collection('users').doc(userCred.user!.uid).set({
          'name': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'uid': userCred.user!.uid,
          'role': 'volunteer',
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Volunteer registered successfully'),
            backgroundColor: Colors.green,
          ),
        );

        goHome();
      } else {
        // ✅ Student flow (Student ID - Firestore only)
        final studentId = emailCtrl.text.trim();

        // Check if this student ID already exists
        final existing = await firestore
            .collection('users')
            .where('studentId', isEqualTo: studentId)
            .get();

        if (existing.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This Student ID is already registered'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => isLoading = false);
          return;
        }

        // Store student info in Firestore
        await firestore.collection('users').add({
          'name': nameCtrl.text.trim(),
          'studentId': studentId,
          'password': passCtrl.text.trim(),
          'role': 'student',
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student registered successfully'),
            backgroundColor: Colors.green,
          ),
        );

        goHome();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign up failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void goHome() {
    if (widget.role.toLowerCase() == 'volunteer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VolunteerHome()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentHome(studentId: emailCtrl.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVolunteer = widget.role.toLowerCase() == 'volunteer';

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role} Sign Up'),
        backgroundColor: const Color(0xFF00A8B5),
      ),
      backgroundColor: const Color(0xFFE0F7F9),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text(
                "Sign Up",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Name field
              const Text('Name*', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: "Enter your name",
                  fillColor: Color(0xffD9D9D9),
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // Email or Student ID
              Text(
                isVolunteer ? 'Email*' : 'Student ID*',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  hintText: isVolunteer
                      ? "Enter your email"
                      : "Enter your student ID",
                  fillColor: const Color(0xffD9D9D9),
                  filled: true,
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // Password field
              const Text('Password*', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Password",
                  fillColor: Color(0xffD9D9D9),
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 40),

              // Sign up button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color(0xffD9D9D9),
                  ),
                  onPressed: isLoading ? null : signUp,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.black87, fontSize: 18),
                        ),
                ),
              ),
              SizedBox(height: 32),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(role: widget.role),
                    ),
                  );
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Have an account already? '),
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
