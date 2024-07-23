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

  Future<void> _clearHistory() async {
    await _firestoreService.clearComplaints(widget.userId);
    setState(() {
      _labComplaints = [];
      _classroomComplaints = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('History cleared successfully')),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear History'),
        content: Text('Are you sure you want to clear your complaint history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearHistory();
            },
            child: Text('Clear'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint History'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _showClearHistoryDialog,
          ),
        ],
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lab Complaints',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              ..._labComplaints.map((complaint) => Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.blueAccent, width: 1),
                    ),
                    child: ListTile(
                      title: Text(complaint['lab']),
                      subtitle: Text(complaint['complaint']),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  )),
              SizedBox(height: 20),
              Text(
                'Classroom Complaints',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              ..._classroomComplaints.map((complaint) => Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.blueAccent, width: 1),
                    ),
                    child: ListTile(
                      title: Text(complaint['classNo']),
                      subtitle: Text(complaint['complaint']),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
