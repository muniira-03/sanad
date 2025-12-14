import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  String sessionType = "public";
  String sessionMode = "online";
  DateTime? selectedDateTime;

  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final appCtrl = TextEditingController();
  final linkCtrl = TextEditingController();

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  String? volunteerName;

  List<String> studentsList = [];
  String? selectedStudent;

  @override
  void initState() {
    super.initState();
    _loadVolunteerName();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      setState(() {
        studentsList = querySnapshot.docs
            .map((doc) => doc['studentId'].toString())
            .toList();
      });
    } catch (e) {
      debugPrint("Error loading students: $e");
    }
  }

  /// Fetch the volunteer name from 'users' collection based on logged-in user ID
  Future<void> _loadVolunteerName() async {
    final user = auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          volunteerName = userDoc.data()?['name'] ?? 'Unknown Volunteer';
        });
      }
    } catch (e) {
      debugPrint("Error fetching volunteer name: $e");
    }
  }

  /// Create session document including volunteerName
  Future<void> createSession() async {
    if (nameCtrl.text.isEmpty ||
        descriptionCtrl.text.isEmpty ||
        (sessionType == "private" && ((selectedStudent ?? '').isEmpty)) ||
        volunteerName == null ||
        selectedDateTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    try {
      final sessionRef = await firestore.collection('sessions').add({
        'volunteerId': auth.currentUser?.uid,
        'sessionName': nameCtrl.text,
        'description': descriptionCtrl.text,
        'type': sessionType,
        'mode': sessionMode,
        'location': sessionMode == "offline" ? locationCtrl.text : null,
        'dateTime': selectedDateTime,
        'studentId': sessionType == "private" ? selectedStudent : null,

        'app': sessionMode == "online" ? appCtrl.text : null,
        'urlLink': sessionMode == "online" ? linkCtrl.text : null,

        'volunteerName': volunteerName,
        'status': 'created',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (sessionType == "public") {
        await firestore.collection('notifications').add({
          'userId': 'all',
          'title': 'New Public Session',
          'message':
              '$volunteerName created a new public session is ${nameCtrl.text}',
          'sessionId': sessionRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      } else if (sessionType == "private") {
        await firestore.collection('notifications').add({
          'userId': selectedStudent,
          'title': 'New Private Session',
          'message':
              '$volunteerName created a private session which is ${nameCtrl.text} and assigned to you ',
          'sessionId': sessionRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session created Successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      nameCtrl.clear();
      descriptionCtrl.clear();
      locationCtrl.clear();
      appCtrl.clear();
      linkCtrl.clear();
      setState(() {
        selectedDateTime = null;
        selectedStudent = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error creating session: $e")));
    }
  }

  /// Show Date and Time Picker
  Future<void> pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    setState(() {
      selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F6F8),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text("Create a Session", style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),

              /// Public/Private Toggle
              ToggleButtons(
                isSelected: [sessionType == "public", sessionType == "private"],
                borderRadius: BorderRadius.circular(12),
                onPressed: (index) {
                  setState(() {
                    sessionType = index == 0 ? "public" : "private";
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Public Session"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Private Session"),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// Session Title
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: "Session Title",
                  fillColor: Color(0xffD9D9D9),
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              /// Session Description
              TextField(
                controller: descriptionCtrl,
                decoration: const InputDecoration(
                  hintText: "Session Description",
                  fillColor: Color(0xffD9D9D9),
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              /// Online/Offline Toggle
              ToggleButtons(
                isSelected: [sessionMode == "online", sessionMode == "offline"],
                borderRadius: BorderRadius.circular(12),
                onPressed: (index) {
                  setState(() {
                    sessionMode = index == 0 ? "online" : "offline";
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Online"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Offline"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// Location Field (only for Offline mode)
              if (sessionMode == "offline")
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    hintText: "Location",
                    fillColor: Color(0xffD9D9D9),
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                )
              else
                Column(
                  children: [
                    TextField(
                      controller: appCtrl,
                      decoration: const InputDecoration(
                        hintText: "App",
                        fillColor: Color(0xffD9D9D9),
                        filled: true,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: linkCtrl,
                      decoration: const InputDecoration(
                        hintText: "Link",
                        fillColor: Color(0xffD9D9D9),
                        filled: true,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              /// Date and Time Picker
              GestureDetector(
                onTap: pickDateTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffD9D9D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedDateTime == null
                        ? "Pick Date and Time"
                        : DateFormat(
                            'yyyy-MM-dd HH:mm',
                          ).format(selectedDateTime!),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (sessionType == "private")
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffD9D9D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedStudent,
                    hint: const Text("Select the Student"),
                    decoration: const InputDecoration(border: InputBorder.none),
                    items: studentsList
                        .map(
                          (student) => DropdownMenuItem(
                            value: student,
                            child: Text(student),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStudent = value;
                      });
                    },
                  ),
                ),

              const SizedBox(height: 30),

              /// Volunteer Name
              Text(
                volunteerName != null
                    ? "Volunteer: $volunteerName"
                    : "Loading volunteer name...",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 30),

              /// Create Session Button
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: createSession,
                  child: const Text(
                    'Create Session',
                    style: TextStyle(color: Colors.black87, fontSize: 18),
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
