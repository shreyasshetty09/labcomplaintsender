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
  bool _isLoading = false;

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    if (!_emailController.text.endsWith('@abc.org.in')) {
      _showAlertDialog('Invalid Email', 'Please use your institutional email.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    User? user = await _authService.signInWithEmailPassword(
      _emailController.text,
      _passwordController.text,
    );

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ITHomePage()),
      );
    } else {
      _showAlertDialog('Login Failed', 'Incorrect email or password.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IT Cell Login'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.security, size: 100, color: Colors.blueGrey),
              SizedBox(height: 20),
              Text(
                'IT Cell Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Institutional Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueGrey,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
              TextButton(
                onPressed: () {
                  // Navigate to Forgot Password page
                },
                child: Text('Forgot Password?'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueGrey,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ITRegisterPage()),
                  );
                },
                child: Text('New User? Register here'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
