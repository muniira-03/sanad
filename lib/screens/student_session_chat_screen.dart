import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentSessionChatScreen extends StatefulWidget {
  final String requestId;
  final String studentId;
  final String subject;
  final String major;
  final String preferredTime;

  const StudentSessionChatScreen({
    super.key,
    required this.requestId,
    required this.studentId,
    required this.subject,
    required this.major,
    required this.preferredTime,
  });

  @override
  State<StudentSessionChatScreen> createState() =>
      _StudentSessionChatScreenState();
}

class _StudentSessionChatScreenState extends State<StudentSessionChatScreen> {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    await _firestore
        .collection('sessionRequests')
        .doc(widget.requestId)
        .collection('messages')
        .add({
          'text': text,
          'senderId': widget.studentId,
          'senderRole': 'student',
          'createdAt': FieldValue.serverTimestamp(),
        });

    await Future.delayed(const Duration(milliseconds: 150));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('sessionRequests')
          .doc(widget.requestId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;

        if (messages.isEmpty) {
          return const Center(child: Text('No messages yet. Start chatting'));
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final data = messages[index].data() as Map<String, dynamic>;
            final text = data['text'] as String? ?? '';
            final senderRole = data['senderRole'] as String? ?? '';
            final isMe = senderRole == 'student';

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue.shade100 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      senderRole == 'volunteer' ? 'Volunteer' : 'Student',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(text),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9F6F8),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Chat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              '${widget.major} - ${widget.subject}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('sessionRequests')
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final status = docData['status'] as String? ?? 'pending';
          final isConfirmed = status == 'confirmed';
          final latestPreferredTime =
              docData['preferredTime'] as String? ?? widget.preferredTime;

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffD9D9D9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Student: ${widget.studentId}"),
                    const SizedBox(height: 4),
                    Text("Preferred time: $latestPreferredTime"),
                    const SizedBox(height: 4),
                    Text(
                      isConfirmed
                          ? "Session confirmed. Chat is closed."
                          : "Wait for the volunteer to confirm the final time.",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildMessagesList()),
              if (!isConfirmed) _buildInputBar(),
            ],
          );
        },
      ),
    );
  }
}
