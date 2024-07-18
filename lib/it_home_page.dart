import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ITHomePage extends StatefulWidget {
  @override
  _ITHomePageState createState() => _ITHomePageState();
}

class _ITHomePageState extends State<ITHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IT Cell Home'),
      ),
      body: FutureBuilder<List<QuerySnapshot>>(
        future: Future.wait([
          _firestore.collection('lab_complaints').get(),
          _firestore.collection('classroom_complaints').get(),
          _firestore.collection('feedbackForms').get(), // Added for feedback
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final labComplaints = snapshot.data![0].docs;
          final classroomComplaints = snapshot.data![1].docs;
          final feedbackForms = snapshot.data![2].docs; // Added for feedback

          List<Widget> labComplaintWidgets = labComplaints.map((complaint) {
            final data = complaint.data() as Map<String, dynamic>;
            final title = data['lab'];
            final description = data['complaint'];
            final userId = data['instructorId'];

            return ListTile(
              title: Text('Lab: $title'),
              subtitle: Text(description),
              onTap: () {
                _showComplaintDialog(context, title, description, userId,
                    complaint.id, 'lab_complaints');
              },
            );
          }).toList();

          List<Widget> classroomComplaintWidgets =
              classroomComplaints.map((complaint) {
            final data = complaint.data() as Map<String, dynamic>;
            final title = data['classNo'];
            final description = data['complaint'];
            final userId = data['name'];

            return ListTile(
              title: Text('Classroom: $title'),
              subtitle: Text(description),
              onTap: () {
                _showComplaintDialog(context, title, description, userId,
                    complaint.id, 'classroom_complaints');
              },
            );
          }).toList();

          List<Widget> feedbackWidgets = feedbackForms.map((feedback) {
            final data = feedback.data() as Map<String, dynamic>;
            final userId = data['userId'];
            final status = data['status'];

            return ListTile(
              title: Text('Feedback from $userId'),
              subtitle: Text('Status: $status'),
              onTap: () {
                _showFeedbackDialog(context, feedback.id, data);
              },
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await _firestore
                      .collection('feedbackForms')
                      .doc(feedback.id)
                      .delete();
                  setState(() {});
                },
              ),
            );
          }).toList();

          return ListView(
            children: [
              ExpansionTile(
                title: Text('Lab Complaints'),
                children: labComplaintWidgets,
              ),
              ExpansionTile(
                title: Text('Classroom Complaints'),
                children: classroomComplaintWidgets,
              ),
              ExpansionTile(
                title: Text('Feedback'),
                children: feedbackWidgets,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showComplaintDialog(
      BuildContext context,
      String title,
      String description,
      String userId,
      String complaintId,
      String collection) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(description),
              ElevatedButton(
                onPressed: () {
                  // Confirm service completion
                  _firestore.collection(collection).doc(complaintId).update({
                    'status': 'confirmed',
                    'serviceDueDate': DateTime.now().add(Duration(days: 7)),
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Confirm'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Mark service as done and send feedback form
                  _firestore.collection(collection).doc(complaintId).update({
                    'status': 'done',
                  });
                  _sendFeedbackForm(userId ?? '');
                  Navigator.of(context).pop();
                },
                child: Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFeedbackDialog(
      BuildContext context, String feedbackId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feedback from ${data['userId']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data['rating'] != null) Text('Rating: ${data['rating']}'),
              if (data['suggestion'] != null)
                Text('Suggestion: ${data['suggestion']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _sendFeedbackForm(String userId) {
    _firestore.collection('feedbackForms').add({
      'userId': userId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
