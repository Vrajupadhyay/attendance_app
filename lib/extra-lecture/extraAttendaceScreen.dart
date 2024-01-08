import 'package:bvm_attendance_system/extra-lecture/extraTakeAttendance.dart';
import 'package:bvm_attendance_system/extra-lecture/extraViewAttendace.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExtraAttendancePage extends StatefulWidget {
  final String username;
  final String password;

  ExtraAttendancePage({required this.username, required this.password});

  @override
  _ExtraAttendancePageState createState() => _ExtraAttendancePageState();
}

class _ExtraAttendancePageState extends State<ExtraAttendancePage> {
  List<dynamic> courses = [];
  final Map<String, Color> classTypeColors = {
    'lecture': Colors.blue,
    'laboratory': Colors.green,
    'tutorial': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extra Lecture Attendance'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator to dashboard
            Navigator.of(context).pushReplacementNamed('/dashboard',
                arguments: {
                  'username': widget.username,
                  'password': widget.password
                });
          },
        ),
      ),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];

          // Get the classType and determine the background color
          final classType = course['classType'];
          final backgroundColor = classTypeColors[classType.toLowerCase()] ??
              Colors.grey; // Default color for unknown class types

          return CourseTile(course: course, backgroundColor: backgroundColor);
        },
      ),
    );
  }
}

class CourseTile extends StatefulWidget {
  final Map<String, dynamic> course;
  final Color backgroundColor;

  CourseTile({required this.course, required this.backgroundColor});

  @override
  _CourseTileState createState() => _CourseTileState();
}

class _CourseTileState extends State<CourseTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      color: widget.backgroundColor,
      margin: EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(widget.course['course_name'],
            style: TextStyle(color: Colors.white)),
        subtitle: Text(widget.course['course_id'],
            style: TextStyle(color: Colors.white)),
        onExpansionChanged: (expanded) {
          setState(() {
            isExpanded = expanded;
          });
        },
        children: [
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExtraTakeAttendancePage(
                            course: widget.course,
                            username: widget.course['username'],
                            Id: widget.course['id'].toString(),
                            courseName: widget.course['course_name'],
                            courseId: widget.course['course_id'],
                          ),
                        ),
                      );
                      // Handle taking attendance for this course
                      // You can add your logic here
                    },
                    child: Text('Take Attendance'),
                    style: ElevatedButton.styleFrom(
                      primary: widget.backgroundColor, // Set background color
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ExtraAttendanceViewerPage(
                            username: widget.course['username'],
                            // Send the current date as the initial date
                            // so that the attendance of the current date is shown
                            initialDate: DateTime.now()
                                .toLocal()
                                .toIso8601String()
                                .split('T')[0],
                            course_id: widget.course['id'].toString(),
                          );
                        },
                      );
                    },
                    child: Text('View Attendance'),
                    style: ElevatedButton.styleFrom(
                      primary: widget.backgroundColor, // Set background color
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
