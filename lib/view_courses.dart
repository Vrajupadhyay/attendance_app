import 'package:bvm_attendance_system/CourseDetailsModal.dart';
import 'package:bvm_attendance_system/EditCourseScreen.dart';
import 'package:bvm_attendance_system/addStudentScreen.dart';
import 'package:bvm_attendance_system/viewStudentScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewCoursesScreen extends StatefulWidget {
  final String username;

  ViewCoursesScreen({required this.username});

  @override
  _ViewCoursesScreenState createState() => _ViewCoursesScreenState();
}

class _ViewCoursesScreenState extends State<ViewCoursesScreen> {
  List<dynamic> courses = [];
  // Define a map of colors based on classType
  final Map<String, Color> classTypeColors = {
    'lecture': Colors.blue,
    'laboratory': Colors.green,
    'tutorial': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final Uri url = Uri.parse(
        'https://web.ieeebvm.in/bvm_attendance/course/getCourseByUsername.php?username=${widget.username}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData is List) {
          setState(() {
            courses = jsonData;
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

  Future<void> _deleteCourse(String id, String courseName) async {
    final confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete $courseName? This action cannot be undone and all attendance records for this course will be deleted.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true); // Confirm
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete != null && confirmDelete) {
      final Uri url = Uri.parse(
          'https://web.ieeebvm.in/bvm_attendance/course/deleteCourse.php?id=/$id');

      try {
        final response = await http.delete(url);

        if (response.statusCode == 200) {
          // Course deleted successfully
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Course deleted successfully'),
          ));
          fetchData(); // Refresh the course list
        } else {
          print('Error deleting course: ${response.statusCode}');
        }
      } catch (e) {
        print('Error deleting course: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Courses'),
      ),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];

          // Get the classType and determine the background color
          final classType = course['classType'];
          final backgroundColor = classTypeColors[classType.toLowerCase()] ??
              Colors.grey; // Default color for unknown class types

          return Card(
            margin: EdgeInsets.all(16.0),
            elevation: 3.0,
            color: backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['course_name'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (course['classType'] == 'Laboratory' ||
                          course['classType'] == 'Tutorial')
                        Text(
                          course['batch'],
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(height: 8.0),
                      Text(
                        'Course ID: ${course['course_id'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: const Color.fromARGB(255, 255, 254, 254),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Handle the edit action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditCourseScreen(
                              id: course['id'].toString(),
                              courseId: course['course_id'] ?? 'N/A',
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Handle the delete action
                        _deleteCourse(
                          course['id'].toString(),
                          course['course_name'] ?? 'N/A',
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.info),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomPopupDialog(
                              title: 'Course Details',
                              courseId: course['course_id'] ?? 'N/A',
                              courseName: course['course_name'] ?? 'N/A',
                              department: course['department'] ?? 'N/A',
                              startDate: course['start_date'] ?? 'N/A',
                              endDate: course['end_date'] ?? 'N/A',
                              selectedTimes: course['selectedTimes'] ?? 'N/A',
                              classType: course['classType'] ?? 'N/A',
                              batch: course['batch'] ?? 'ALL',
                              content: '',
                              username: '',
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    shrinkWrap:
                        true, // Allows the ListView to adapt to its content size
                    scrollDirection:
                        Axis.vertical, // Displays buttons in a vertical column
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddStudentScreen(
                                username: widget.username,
                                courseId: course['course_id'] ?? 'N/A',
                                batch: course['batch'] ?? 'N/A',
                                classType: course['classType'] ?? 'N/A',
                              ),
                            ),
                          );
                          // Handle Add Student button click
                        },
                        child: Text('Add Student'),
                      ),
                      SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewStudentsScreen(
                                username: widget.username,
                                courseId: course['course_id'] ?? 'N/A',
                                batch: course['batch'] ?? 'N/A',
                                classType: course['classType'] ?? 'N/A',
                              ),
                            ),
                          );
                          // Handle View Student button click
                        },
                        child: Text('View Students'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
              ],
            ),
          );
        },
      ),
    );
  }
}
