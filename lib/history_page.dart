import 'package:flutter/material.dart';
import 'firestore_service.dart';

class HistoryPage extends StatefulWidget {
  final String userId;

  HistoryPage({required this.userId});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _labComplaints = [];
  List<Map<String, dynamic>> _classroomComplaints = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    List<Map<String, dynamic>> labComplaints =
        await _firestoreService.getLabComplaints(widget.userId);
    List<Map<String, dynamic>> classroomComplaints =
        await _firestoreService.getClassroomComplaints(widget.userId);

    setState(() {
      _labComplaints = labComplaints;
      _classroomComplaints = classroomComplaints;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint History'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text('Lab Complaints', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ..._labComplaints.map((complaint) => ListTile(
                title: Text(complaint['lab']),
                subtitle: Text(complaint['complaint']),
              )),
          SizedBox(height: 20),
          Text('Classroom Complaints', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ..._classroomComplaints.map((complaint) => ListTile(
                title: Text(complaint['classNo']),
                subtitle: Text(complaint['complaint']),
              )),
        ],
      ),
    );
  }
}
