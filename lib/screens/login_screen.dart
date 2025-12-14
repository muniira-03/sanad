import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad_app/screens/signup_screen.dart';
import 'volunteer_home.dart';
import 'student_home.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({required this.role, super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController(); // email or studentId
  final passCtrl = TextEditingController();

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      // ✅ Volunteer Login with Firebase Auth
      if (widget.role.toLowerCase() == 'volunteer') {
        await auth.signInWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Volunteer login successful'),
            backgroundColor: Colors.green,
          ),
        );
        goHome();
      } else {
        // ✅ Student Login with Firestore (studentId)
        final studentId = emailCtrl.text.trim();
        final password = passCtrl.text.trim();

        // Fetch student data
        final query = await firestore
            .collection('users')
            .where('studentId', isEqualTo: studentId)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid Student ID'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => isLoading = false);
          return;
        }

        final userData = query.docs.first.data();

        if (userData['password'] == password) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student login successful'),
              backgroundColor: Colors.green,
            ),
          );
          goHome();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
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
        title: Text('${widget.role} Login'),
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
                "Login",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Email or Student ID
              Text(
                isVolunteer ? 'Email*' : 'Student ID*',
                style: const TextStyle(color: Colors.black, fontSize: 16),
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

              // Password
              const Text(
                'Password*',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Enter your password",
                  fillColor: Color(0xffD9D9D9),
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 40),

              // Login Button
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
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Login',
                          style: TextStyle(color: Colors.black87, fontSize: 18),
                        ),
                ),
              ),

              if (isVolunteer) ...[
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignupScreen(role: widget.role),
                      ),
                    );
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Don't Have an account?  "),
                        Text(
                          'Sign up',
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
            ],
          ),
        ),
      ),
    );
  }
}
