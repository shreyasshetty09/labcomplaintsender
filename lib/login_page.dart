import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register_page.dart';
import 'it_login_page.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    User? user = await _authService.signInWithEmailPassword(
                        _emailController.text, _passwordController.text);
                    if (user != null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Success'),
                          content: Text('Logged in successfully!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('Wrong credentials!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  child: Text('Login'),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    User? user = await _authService.signInWithGoogle();
                    if (user != null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Success'),
                          content: Text('Logged in successfully!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('Wrong credentials!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  child: Text('Login with Google'),
                ),
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
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text('New User? Register here'),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ITLoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  child: Text('IT Cell Login',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
