import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddStudentScreen extends StatefulWidget {
  final String courseId;
  final String username;
  final String batch;
  final String classType;

  AddStudentScreen(
      {required this.courseId,
      required this.username,
      required this.batch,
      required this.classType});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController uidController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  // TextEditingController genderController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController emailIdController = TextEditingController();
  TextEditingController currentSemController = TextEditingController();

  String? successMessage;

  Future<void> _addStudent() async {
    final Uri url =
        Uri.parse('https://web.ieeebvm.in/bvm_attendance/student/createStudent.php');
    final Map<String, dynamic> studentData = {
      'uid': uidController.text,
      'fullname': fullnameController.text,
      'department': departmentController.text,
      // 'gender': genderController.text,
      'contact_number': contactNumberController.text,
      'emailid': emailIdController.text,
      'current_sem': currentSemController.text,
      'course_id': widget.courseId, // Passed course ID
      'batch': widget.batch, // Passed batch
      'classType': widget.classType, // Passed class type
      'username': widget.username, // Passed username
    };

    final http.Response response = await http.post(
      url,
      body: json.encode(studentData),
      headers: {'Content-Type': 'application/json'},
    );

    // print(response.body);

    if (response.statusCode == 200) {
      // Student added successfully
      setState(() {
        successMessage = 'Student added successfully';
      });

      // Clear form fields
      uidController.clear();
      fullnameController.clear();
      departmentController.clear();
      // genderController.clear();
      contactNumberController.clear();
      emailIdController.clear();
      currentSemController.clear();
    } else {
      // Student add failed
      setState(() {
        successMessage = 'Student add failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: uidController,
                decoration: InputDecoration(
                  labelText: 'UID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter UID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: fullnameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Full Name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: departmentController,
                decoration: InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Department';
                  }
                  return null;
                },
              ),
              // SizedBox(height: 16),
              // TextFormField(
              //   controller: genderController,
              //   decoration: InputDecoration(
              //     labelText: 'Gender',
              //     border: OutlineInputBorder(),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter Gender';
              //     }
              //     return null;
              //   },
              // ),
              SizedBox(height: 16),
              TextFormField(
                controller: contactNumberController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Contact Number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: emailIdController,
                decoration: InputDecoration(
                  labelText: 'Email ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Email ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: currentSemController,
                decoration: InputDecoration(
                  labelText: 'Current Semester',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Current Semester';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Implement the add student function
                  if (_formKey.currentState!.validate()) {
                    _addStudent();
                  }
                },
                child: Text('Add Student'),
              ),
              if (successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: AnimatedContainer(
                    duration: Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        successMessage!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
