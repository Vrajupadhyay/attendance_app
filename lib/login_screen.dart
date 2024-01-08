import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('username') != null &&
        prefs.getString('password') != null) {
      // If locally stored credentials are available, check the session on the server
      final response = await verifySession(
        prefs.getString('username')!,
        prefs.getString('password')!,
      );

      if (response.statusCode == 200) {
        // Session is active, redirect to the dashboard
        Navigator.of(context).pushReplacementNamed('/dashboard', arguments: {
          'username': prefs.getString('username'),
          'password': prefs.getString('password')
        });
      }
    }
  }

  Future<http.Response> verifySession(String username, String password) async {
    final url = Uri.parse('https://web.ieeebvm.in/bvm_attendance/faculty/session.php');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
    return response;
  }

  Future<void> loginUser() async {
    final url = Uri.parse('https://web.ieeebvm.in/bvm_attendance/faculty/login.php');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey('message')) {
          // Successful login, save session and redirect to the dashboard
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('username', usernameController.text);
          prefs.setString('password', passwordController.text);

          // Redirect to the dashboard with arguments
          Navigator.pushReplacementNamed(
            context,
            '/dashboard',
            arguments: {
              'username': usernameController.text,
              'password': passwordController.text,
            },
          );

        } else {
          // Login failed, show error message
          _showSnackBar('Login failed. Please check your credentials.');
        }
      } else if (response.statusCode == 401) {
        // Unauthorized access, show error message
        _showSnackBar('Invalid username or password');
      } else {
        // Handle other status codes as needed
        _showSnackBar('An error occurred. Please try again.');
      }
    } catch (e) {
      // Handle any network or other errors
      _showSnackBar('An error occurred: $e');
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    );
    _scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Opacity(
                opacity: 0.3, // Adjust opacity as needed
                child: Image.asset(
                  'assets/images/bvmhero.jpg', // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        'assets/images/bvmlogo.png',
                        width: 150,
                        height: 150,
                      )),
                  Text(
                    'BIRLA VISHVAKARMA MAHAVIDYALAYA',
                    style: TextStyle(
                      color: Colors.blue, // Text color
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: loginUser,
                    child: Text('Login'),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Navigate to registration screen
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: Text('Don\'t have an account? Register here'),
                  ),
                ],
              ),
            ),
          ],
        ),
        //footer section
        bottomNavigationBar: BottomAppBar(
          color: Colors.blue,
          child: Container(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '© BIRLA VISHVAKARMA MAHAVIDYALAYA - 2024',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
