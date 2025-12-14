import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'student_session_chat_screen.dart';

class StudentRequestsScreen extends StatelessWidget {
  final String studentId;
  final _firestore = FirebaseFirestore.instance;

  StudentRequestsScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F6F8),
      appBar: AppBar(
        title: const Text('My Requests'),
        backgroundColor: const Color(0xFFD9F6F8),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('sessionRequests')
            .where('studentId', isEqualTo: studentId)
            // .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(
              child: Text('You have no session requests yet.'),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;

              final major = data['major'] ?? '';
              final subject = data['subject'] ?? '';
              final preferredTime = data['preferredTime'] ?? '';
              final status = data['status'] ?? 'pending';

              return Card(
                color: const Color(0xffD9D9D9),
                child: ListTile(
                  title: Text('$major - $subject'),
                  subtitle: Text('Preferred: $preferredTime\nStatus: $status'),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentSessionChatScreen(
                          requestId: doc.id,
                          studentId: studentId,
                          subject: subject,
                          major: major,
                          preferredTime: preferredTime,
                        ),
                      ),
                    );
                  },
                  trailing: const Icon(Icons.chat_bubble_outline),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
