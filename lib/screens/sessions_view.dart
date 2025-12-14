import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SessionsView extends StatefulWidget {
  final String studentId;
  const SessionsView({super.key, required this.studentId});

  @override
  State<SessionsView> createState() => _SessionsViewState();
}

class _SessionsViewState extends State<SessionsView> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7F9),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: getStudentData(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userSnapshot.hasError) {
              return Center(
                child: Text('Error loading user: ${userSnapshot.error}'),
              );
            }

            final userData = userSnapshot.data;
            if (userData == null) {
              return const Center(child: Text('User data not found.'));
            }

            final role = userData['role'] as String? ?? 'student';
            final studentId = userData['studentId']?.toString();

            return StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('sessions').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading sessions: ${snapshot.error}'),
                  );
                }

                final sessions = snapshot.data?.docs ?? [];

                final publicSessions = sessions.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return data['type'] == 'public';
                }).toList();

                final privateSessions = sessions.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  if (data['type'] != 'private') return false;
                  if (role == 'volunteer') return true;
                  if (studentId == null) return false;
                  return data['studentId']?.toString() == studentId;
                }).toList();

                return ListView(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "Public Sessions",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildList(publicSessions),
                    const SizedBox(height: 30),
                    const Text(
                      "Private Sessions",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildList(privateSessions),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildList(List<QueryDocumentSnapshot> sessions) {
    if (sessions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: Text('No sessions to show')),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final data = sessions[index].data() as Map<String, dynamic>;
        final sessionId = sessions[index].id;
        return sessionTile(data, sessionId);
      },
    );
  }

  Widget sessionTile(Map<String, dynamic> data, String sessionId) {
    return GestureDetector(
      onTap: () async {
        final mode = (data['mode'] ?? '').toString();
        final rawLink = (data['urlLink'] ?? '').toString().trim();

        if (mode == "online" && rawLink.isNotEmpty) {
          try {
            final uri = Uri.tryParse(rawLink);

            if (uri == null ||
                !(uri.hasScheme &&
                    (uri.scheme == 'http' || uri.scheme == 'https'))) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'الرابط غير صالح، تأكد إنك حاط https:// في البداية',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final opened = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );

            if (!opened) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تعذر فتح الرابط'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('There is an error in link $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meeting you in the specific location'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/headphone.png',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['sessionName'] ?? 'Unnamed',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    'Description: ${ data['description']??'----'}',maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text("Type: ${data['type'] ?? '-'}"),
                  Text("Mode: ${data['mode'] ?? '-'}"),

                  if (data['mode'] == "offline")
                    Text("Location: ${data['location'] ?? '-'}"),

                  const SizedBox(height: 4),

                  Text(
                    "Volunteer: ${data['volunteerName'] ?? '-'}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Date: ${data['dateTime'] != null ? data['dateTime'].toDate().toString().substring(0, 16) : '-'}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
