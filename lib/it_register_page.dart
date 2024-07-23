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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  bool _isValidId(String id) {
    List<String> validIds = ['ITR001', 'ITR002', 'ITR003', 'ITR004', 'ITR005'];
    return validIds.contains(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IT Cell Register'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/register_icon.png'), // Add your own asset
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: 20),
              Text(
                'Register to IT Cell',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(_firstNameController, 'First Name', Icons.person),
              _buildTextField(_lastNameController, 'Last Name', Icons.person),
              _buildTextField(
                  _idController, 'ID (starts with ITR)', Icons.badge),
              _buildTextField(_passwordController, 'Password', Icons.lock,
                  obscureText: true),
              _buildTextField(
                  _confirmPasswordController, 'Confirm Password', Icons.lock,
                  obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_passwordController.text.isEmpty ||
                      _confirmPasswordController.text.isEmpty ||
                      _firstNameController.text.isEmpty ||
                      _lastNameController.text.isEmpty ||
                      _idController.text.isEmpty) {
                    _showErrorDialog('All fields are required.');
                    return;
                  }
                  if (_passwordController.text !=
                      _confirmPasswordController.text) {
                    _showErrorDialog('Passwords do not match.');
                    return;
                  }
                  if (!_isValidId(_idController.text)) {
                    _showErrorDialog('ID must be between ITR001 and ITR005.');
                    return;
                  }
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
                    _showErrorDialog('Registration failed. Please try again.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.blueAccent),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        obscureText: obscureText,
      ),
    );
  }
}
