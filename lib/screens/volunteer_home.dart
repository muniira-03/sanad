import 'package:flutter/material.dart';
import 'package:sanad_app/screens/create_session.dart';
import 'package:sanad_app/screens/notifications_screen.dart';
import 'volunteer_profile.dart';
import 'volunteer_requested.dart';

class VolunteerHome extends StatefulWidget {
  const VolunteerHome({super.key});

  @override
  State<VolunteerHome> createState() => _VolunteerHomeState();
}

class _VolunteerHomeState extends State<VolunteerHome> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    CreateSessionScreen(),
    VolunteerRequested(),
    NotificationsScreen(),
    VolunteerProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
