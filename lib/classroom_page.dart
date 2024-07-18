import 'package:flutter/material.dart';
import 'firestore_service.dart';

class ClassroomPage extends StatefulWidget {
  @override
  _ClassroomPageState createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classNoController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classroom Complaint'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Your Name'),
            ),
            TextField(
              controller: _classNoController,
              decoration: InputDecoration(labelText: 'Classroom Number'),
            ),
            TextField(
              controller: _complaintController,
              decoration: InputDecoration(labelText: 'Complaint'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty &&
                    _classNoController.text.isNotEmpty &&
                    _complaintController.text.isNotEmpty) {
                  await _firestoreService.addClassroomComplaint(
                    _nameController.text,
                    _classNoController.text,
                    _complaintController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Complaint submitted successfully')),
                  );
                  _nameController.clear();
                  _classNoController.clear();
                  _complaintController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
