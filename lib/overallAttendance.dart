import 'package:bvm_attendance_system/studentAttendanceByPercentage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MonthlyAttendance extends StatefulWidget {
  final String username;

  MonthlyAttendance({required this.username});

  @override
  _MonthlyAttendanceState createState() => _MonthlyAttendanceState();
}

class _MonthlyAttendanceState extends State<MonthlyAttendance> {
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
        title: Text('OverAll Attendance Page'),
      ),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          // Get the classType and determine the background color
          final classType = course['classType'];
          final backgroundColor =
              classTypeColors.containsKey(classType.toLowerCase())
                  ? classTypeColors[classType.toLowerCase()]!
                  : Colors.grey; // Default color for unknown class types

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

  void _navigateToStudentInfoPage() {
    // Use Navigator to push the StudentInfoPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentAttendancePercentage(
          course_id: widget.course['id'].toString(),
          username: widget.course['username'],
          courseId: widget.course['course_id'],
          courseName: widget.course['course_name'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.backgroundColor,
      child: GestureDetector(
        onTap: () {
          // Call the provided onTap function when tapped
          _navigateToStudentInfoPage();
        },
        child: ListTile(
          leading: CircleAvatar(
            child: Text(
              widget.course['course_name'][0],
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            widget.course['course_name'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            widget.course['course_id'],
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
