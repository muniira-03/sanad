import 'package:flutter/material.dart';
import 'package:sanad_app/screens/request_session_screen.dart';
import 'package:sanad_app/screens/sessions_view.dart';
import 'package:sanad_app/screens/student_notification__screen.dart';
import 'package:sanad_app/screens/student_profile.dart';
import 'package:sanad_app/screens/student_requests_screen.dart';

class StudentHome extends StatefulWidget {
  final String studentId;

  const StudentHome({super.key, required this.studentId});
  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int idx = 0;
  List<Widget> get screens => [
    SessionsView(studentId: widget.studentId),
    RequestSessionScreen(studentId: widget.studentId),
    StudentRequestsScreen(studentId: widget.studentId),
    StudentNotificationScreen(studentId: widget.studentId),
    StudentProfile(studentId: widget.studentId),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[idx],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}
