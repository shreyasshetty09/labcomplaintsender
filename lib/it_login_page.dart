import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'it_register_page.dart';
import 'auth_service.dart';
import 'it_home_page.dart';

class ITLoginPage extends StatefulWidget {
  @override
  _ITLoginPageState createState() => _ITLoginPageState();
}

class _ITLoginPageState extends State<ITLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IT Cell Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Institutional Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_emailController.text.endsWith('@abc.org.in')) {
                  User? user = await _authService.signInWithEmailPassword(
                      _emailController.text, _passwordController.text);
                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ITHomePage()),
                    );
                  } else {
                    // Show error message
                  }
                } else {
                  // Show error message
                }
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to Forgot Password page
              },
              child: Text('Forgot Password?'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ITRegisterPage()),
                );
              },
              child: Text('New User? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}
