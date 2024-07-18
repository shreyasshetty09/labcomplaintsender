import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'lab_page.dart';
import 'classroom_page.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'history_page.dart'; // Ensure this import is added

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
      // Handle error (e.g., show a message to the user)
      print('Error fetching feedbacks: $e');
    }
  }

  void _openFeedbackForm(Map<String, dynamic> feedback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int _rating = 0;
        TextEditingController _suggestionController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Feedback Form'),
              content: Column(
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
                    decoration: InputDecoration(labelText: 'Suggestions'),
                  ),
                ],
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
                    _fetchFeedbacks(); // Refresh feedback list
                  },
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LabPage()),
              );
            },
            child: Text('Lab'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClassroomPage()),
              );
            },
            child: Text('Classroom'),
          ),
          Expanded(
            child: _feedbacks.isEmpty
                ? Center(child: Text('No feedbacks yet'))
                : ListView.builder(
                    itemCount: _feedbacks.length,
                    itemBuilder: (context, index) {
                      final feedback = _feedbacks[index];
                      final userId = feedback['userId'] ?? 'Unknown';
                      final status = feedback['status'] ?? 'Unknown';
                      return ListTile(
                        title: Text('Feedback from $userId'),
                        subtitle: Text('Status: $status'),
                        onTap: () {
                          _openFeedbackForm(feedback);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
