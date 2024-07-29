import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the login page

class ITHomePage extends StatefulWidget {
  @override
  _ITHomePageState createState() => _ITHomePageState();
}

class _ITHomePageState extends State<ITHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _markAllAsRead(String collection) async {
    final complaints = await _firestore
        .collection(collection)
        .where('status', isEqualTo: 'unread')
        .get();

    for (var complaint in complaints.docs) {
      await _firestore.collection(collection).doc(complaint.id).update({
        'status': 'read',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IT Cell Home'),
        backgroundColor: Colors.blueAccent,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collectionGroup('complaints')
                .where('status', isEqualTo: 'unread')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {},
                );
              }

              final newComplaintsCount = snapshot.data!.docs.length;

              return IconButton(
                icon: Stack(
                  children: [
                    Icon(Icons.notifications),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '$newComplaintsCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
                onPressed: () {},
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<QuerySnapshot>>(
        future: Future.wait([
          _firestore.collection('lab_complaints').get(),
          _firestore.collection('classroom_complaints').get(),
          _firestore.collection('feedbackForms').get(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final labComplaints = snapshot.data![0].docs;
          final classroomComplaints = snapshot.data![1].docs;
          final feedbackForms = snapshot.data![2].docs;

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              _buildExpansionTile(
                'Lab Complaints',
                labComplaints,
                'lab_complaints',
              ),
              _buildExpansionTile(
                'Classroom Complaints',
                classroomComplaints,
                'classroom_complaints',
              ),
              _buildFeedbackExpansionTile(feedbackForms),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExpansionTile(
      String title, List<QueryDocumentSnapshot> complaints, String collection) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
      onExpansionChanged: (bool expanded) {
        if (expanded) {
          _markAllAsRead(collection);
        }
      },
      children: complaints.map((complaint) {
        final data = complaint.data() as Map<String, dynamic>;
        final complaintTitle = data['lab'] ?? data['classNo'];
        final description = data['complaint'];
        final userId = data['instructorId'] ?? data['name'];
        final status = data['status'];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.blueAccent),
          ),
          child: ListTile(
            leading: Icon(
              status == 'unread'
                  ? Icons.mark_email_unread
                  : Icons.mark_email_read,
              color: status == 'unread' ? Colors.redAccent : Colors.green,
            ),
            title: Text(
                '${collection == 'lab_complaints' ? 'Lab' : 'Classroom'}: $complaintTitle'),
            subtitle: Text(description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    _showComplaintDialog(
                      context,
                      complaintTitle,
                      description,
                      userId,
                      complaint.id,
                      collection,
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    _showDeleteComplaintDialog(
                        context, complaint.id, collection);
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackExpansionTile(
      List<QueryDocumentSnapshot> feedbackForms) {
    return ExpansionTile(
      title: Text(
        'Feedback',
        style: TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: feedbackForms.map((feedback) {
        final data = feedback.data() as Map<String, dynamic>;
        final userId = data['userId'];
        final rating = data['rating'] ?? 'No rating';
        final comments = data['comments'] ?? 'No comments';
        final status = data['status'];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.blueAccent),
          ),
          child: ListTile(
            leading: Icon(Icons.feedback, color: Colors.blueAccent),
            title: Text('Feedback from $userId'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rating: $rating'),
                Text('Comments: $comments'),
                Text('Status: $status'),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                await _firestore
                    .collection('feedbackForms')
                    .doc(feedback.id)
                    .delete();
                setState(() {});
              },
            ),
            onTap: () {
              _showFeedbackDialog(context, feedback.id, data);
            },
          ),
        );
      }).toList(),
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
        bool isConfirmed = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title, style: TextStyle(color: Colors.blueAccent)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(description),
                  SizedBox(height: 20),
                  if (!isConfirmed)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isConfirmed = true;
                        });
                        _firestore
                            .collection(collection)
                            .doc(complaintId)
                            .update({
                          'status': 'confirmed',
                          'serviceDueDate':
                              DateTime.now().add(Duration(days: 7)),
                        });
                      },
                      child: Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                    ),
                  if (isConfirmed)
                    Icon(Icons.check_circle, color: Colors.green, size: 40),
                ],
              ),
              actions: [
                if (isConfirmed)
                  ElevatedButton(
                    onPressed: () async {
                      await _firestore
                          .collection(collection)
                          .doc(complaintId)
                          .update({'status': 'done'});
                      _sendFeedbackForm(userId);
                      Navigator.of(context).pop();
                      _showDeleteComplaintDialog(
                          context, complaintId, collection);
                    },
                    child: Text('Done'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
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
      },
    );
  }

  void _showDeleteComplaintDialog(
      BuildContext context, String complaintId, String collection) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Complaint',
              style: TextStyle(color: Colors.blueAccent)),
          content: Text('Are you sure you want to delete this complaint?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _firestore
                    .collection(collection)
                    .doc(complaintId)
                    .delete();
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
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
          title: Text('Feedback from ${data['userId']}',
              style: TextStyle(color: Colors.blueAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data['rating'] != null) Text('Rating: ${data['rating']}'),
              if (data['comments'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text('Comments: ${data['comments']}'),
                ),
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
    });
  }
}
