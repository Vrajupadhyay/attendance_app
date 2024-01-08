import 'package:bvm_attendance_system/addStudentScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewStudentsScreen extends StatefulWidget {
  final String
      courseId; // Pass the course ID to view students for a specific course.
  final String username;
  final String batch;
  final String classType;

  ViewStudentsScreen(
      {required this.courseId,
      required this.username,
      required this.batch,
      required this.classType});

  @override
  _ViewStudentsScreenState createState() => _ViewStudentsScreenState();
}

class _ViewStudentsScreenState extends State<ViewStudentsScreen> {
  List<dynamic> students = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final Uri url = Uri.parse(
        'https://web.ieeebvm.in/bvm_attendance/student/getStudentByCourseId.php?course_id=${widget.courseId}&batch=${widget.batch}&username=${widget.username}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData is List) {
          setState(() {
            students = jsonData;
          });
        } else {
          print('Data is null or not a list');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteStudent(String id) async {
    final Uri url = Uri.parse(
        'https://web.ieeebvm.in/bvm_attendance/student/deleteStudent.php?id=$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // Student deleted successfully
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Student deleted successfully'),
        ));
        fetchData(); // Refresh the student list
      } else {
        print('Error deleting student: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting student: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Students'),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];

          return Card(
            elevation: 3.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(student['fullname'] ?? 'N/A'),
              subtitle: Text(student['uid'] ?? 'N/A'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Show a confirmation dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Student'),
                            content: Text(
                                'Are you sure you want to delete this student?'),
                            actions: [
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () {
                                  // Handle the delete action
                                  _deleteStudent(student['id'].toString());
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the add student action
          // Navigate to the add student screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddStudentScreen(
                  courseId: widget.courseId,
                  username: widget.username,
                  batch: widget.batch,
                  classType: widget.classType),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
