import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'session_chat_screen.dart';

class VolunteerRequested extends StatelessWidget {
  final firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F6F8),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text("requested sessions", style: TextStyle(fontSize: 24)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('sessionRequests')
                    .where('status', isEqualTo: 'pending')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sessions = snapshot.data!.docs;
                  if (sessions.isEmpty) {
                    return const Center(child: Text("No pending requests."));
                  }

                  return ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final data = session.data() as Map<String, dynamic>;

                      final studentId = data['studentId'] ?? '';
                      final major = data['major'] ?? '';
                      final subject = data['subject'] ?? '';
                      final preferredTime = data['preferredTime'] ?? 'Not set';

                      return Card(
                        color: const Color(0xffD9D9D9),
                        child: ListTile(
                          title: Text(
                            "$studentId requested a session for the $major to explain $subject",
                          ),
                          subtitle: Text("Preferred time: $preferredTime"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SessionChatScreen(
                                  requestId: session.id,
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
            ),
          ],
        ),
      ),
    );
  }
}
