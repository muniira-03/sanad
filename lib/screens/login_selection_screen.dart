import 'package:flutter/material.dart';
import 'login_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7F9),
      body: Center(
        child: Column(
          children: [
            Spacer(),
            Text(
              'ســـــنــــــــــد',
              style: TextStyle(
                fontSize: 40,
                color: Color(0xff7FC7D9),
                shadows: [
                  BoxShadow(offset: Offset(1, 0), color: Colors.black38),
                ],
              ),
            ),
            Spacer(),
            Text('log in    sign in', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
                  ),
                  backgroundColor: Color(0xffD9D9D9),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(role: 'volunteer'),
                  ),
                ),
                child: Text(
                  'Volunteer',
                  style: TextStyle(color: Colors.black87, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
                  ),
                  backgroundColor: Color(0xffD9D9D9),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(role: 'student'),
                  ),
                ),
                child: Text(
                  'Student',
                  style: TextStyle(color: Colors.black87, fontSize: 18),
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
