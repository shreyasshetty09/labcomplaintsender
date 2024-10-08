import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'lab_page.dart';
import 'classroom_page.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _feedbacks = [];

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  Future<void> _fetchFeedbacks() async {
    try {
      List<Map<String, dynamic>> feedbacks =
          await _firestoreService.getFeedbackForms();
      setState(() {
        _feedbacks = feedbacks;
      });
    } catch (e) {
      print('Error fetching feedbacks: $e');
    }
  }

  void _openFeedbackForm(Map<String, dynamic> feedback) {
    if (feedback['status'] == 'submitted') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feedback has already been submitted.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int _rating = 0;
        TextEditingController _suggestionController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Text('Feedback Form'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Rate your experience:'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                          ),
                          color: Colors.amber,
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    TextField(
                      controller: _suggestionController,
                      decoration: InputDecoration(
                        labelText: 'Suggestions',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _firestoreService.submitFeedback(
                      feedback['id'],
                      _rating,
                      _suggestionController.text,
                    );
                    Navigator.of(context).pop();
                    _fetchFeedbacks();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blueGrey,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/history', arguments: user?.uid);
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LabPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text('Lab'),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClassroomPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text('Classroom'),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _feedbacks.isEmpty
                    ? Center(child: Text('No feedbacks yet'))
                    : ListView.builder(
                        itemCount: _feedbacks.length,
                        itemBuilder: (context, index) {
                          final feedback = _feedbacks[index];
                          final userId = feedback['userId'] ?? 'Unknown';
                          final status = feedback['status'] ?? 'Unknown';
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: BorderSide(
                                color: status == 'pending'
                                    ? Colors.orange
                                    : status == 'submitted'
                                        ? Colors.green
                                        : Colors.red,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              title: Text('Feedback from $userId'),
                              subtitle: Text('Status: $status'),
                              onTap: () {
                                _openFeedbackForm(feedback);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
