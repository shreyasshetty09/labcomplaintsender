import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class ITRegisterPage extends StatefulWidget {
  @override
  _ITRegisterPageState createState() => _ITRegisterPageState();
}

class _ITRegisterPageState extends State<ITRegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IT Cell Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'ID (starts with ITR)'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_passwordController.text ==
                    _confirmPasswordController.text) {
                  User? user = await _authService.registerWithEmailPassword(
                    _idController.text + '@abc.org.in',
                    _passwordController.text,
                  );
                  if (user != null) {
                    await _firestoreService.addITUser(
                      user.uid,
                      _firstNameController.text,
                      _lastNameController.text,
                      _idController.text,
                    );
                    Navigator.pop(context);
                  } else {
                    // Show error message
                  }
                } else {
                  // Show error message
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
