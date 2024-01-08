import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: FacultyDetailsPage(),
  ));
}

class FacultyDetailsPage extends StatefulWidget {
  final String? username;
  final String? password;
  const FacultyDetailsPage({Key? key, this.username, this.password})
      : super(key: key);
  @override
  _FacultyDetailsPageState createState() => _FacultyDetailsPageState();
}

class _FacultyDetailsPageState extends State<FacultyDetailsPage> {
  late Future<List<Map<String, dynamic>>> _facultyDetailsList;

  @override
  void initState() {
    super.initState();
    _facultyDetailsList = fetchFacultyDetailsList();
  }

  Future<List<Map<String, dynamic>>> fetchFacultyDetailsList() async {
    final response = await http.get(
      Uri.parse(
          'https://web.ieeebvm.in/bvm_attendance/faculty/getFaculty.php?username=${widget.username}&password=${widget.password}'),
    );

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> facultyList = [
        json.decode(response.body)
      ]; // Wrap the response in a list
      // print(facultyList);
      return facultyList;
    } else {
      throw Exception('Failed to load faculty details');
    }
  }


  // updatePassword function
  Future<http.Response> updatePassword(String id, String password) async {
    final Map<String, dynamic> data = {
      'id': id,
      'password': password,
    };

    final http.Response response = await http.put(
      Uri.parse('https://web.ieeebvm.in/bvm_attendance/faculty/updatePassword.php'),
      headers: {
        'Content-Type': 'application/json', // Set the content type
      },
      body: json.encode({
        'id': id,
        'password': password,
      })
     
    );

    // Check the response status code
    if (response.statusCode == 200) {
      // Password updated successfully
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Password updated successfully'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      // redirect to login page
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      // Failed to update password
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update password'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faculty Profile'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _facultyDetailsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final facultyList = snapshot.data;
            final faculty = facultyList?.first;

            return Stack(
              children: [
                // Background Color
                Container(
                  color: Colors.blue, // Background color
                  height: 200.0, // Adjust height as needed
                ),
                ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    // Profile Card
                    Card(
                      elevation: 4.0,
                      margin: EdgeInsets.all(0.0),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                'Name: ${faculty!['fullname']}',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${faculty['email']}'),
                                  Text('Phone: ${faculty['contact_number']}'),
                                  Text('Department: ${faculty['department']}'),
                                  Text('Username: ${faculty['username']}'),
                                  // Text('Password: ${faculty['password']}'),
                                  // Text('Faculty ID: ${faculty['fid']}')
                                  // Add more user information here
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0), // Spacer
                    // Change Password Button
                    ElevatedButton(
                      onPressed: () {
                        _showChangePasswordDialog(faculty['fid']);
                      },
                      child: Text('Change Password'),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _showChangePasswordDialog(int facultyId) {
    TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String new_password = newPasswordController.text;
                // Check if new_password is not empty and call updatePassword
                if (new_password.isNotEmpty) {
                  updatePassword(facultyId.toString(), new_password);
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
