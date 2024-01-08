import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  final String? username;
  final String? password;

  DashboardScreen({required this.username, required this.password});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> todayData = [];
  List<dynamic> enrolledCourses = [];

  @override
  void initState() {
    super.initState();

    // Check if the username is null or empty
    if (widget.username == null ||
        widget.username!.isEmpty ||
        widget.password == null ||
        widget.password!.isEmpty) {
      // Navigate back to the login page
      Navigator.of(context).pushReplacementNamed('/login');
    }

    // Fetch today's lecture data and enrolled courses
    fetchTodayLecture();
    fetchEnrolledCourses();
  }

  Future<void> fetchTodayLecture() async {
    try {
      final Uri url = Uri.parse(
          'https://web.ieeebvm.in/bvm_attendance/faculty/dashboard/dashboard.php?username=${widget.username}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData.isNotEmpty) {
          setState(() {
            todayData = jsonData;
          });
        } else {
          print('No lecture data found for today.');
          // Handle the case where no lecture data is found
        }
      } else if (response.statusCode == 401) {
        // Unauthorized access, session not started
        print('Session not started. Logging out...');
        logout();
      } else {
        print('Error: ${response.statusCode}');
        // Handle other status codes as needed
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchEnrolledCourses() async {
    try {
      final Uri url = Uri.parse(
          'https://web.ieeebvm.in/bvm_attendance/course/getCourseByUsername.php?username=${widget.username}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData.isNotEmpty) {
          setState(() {
            enrolledCourses = jsonData;
          });
        } else {
          print('No enrolled courses found.');
          // Handle the case where no enrolled courses are found
        }
      } else if (response.statusCode == 401) {
        // Unauthorized access, session not started
        print('Session not started. Logging out...');
        logout();
      } else {
        print('Error: ${response.statusCode}');
        // Handle other status codes as needed
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> logout() async {
    final url = Uri.parse('https://web.ieeebvm.in/bvm_attendance/faculty/logout.php');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Clear the local session and navigate to the login screen
        await clearSession();
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        // Handle other status codes as needed
        print('Logout failed. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any network or other errors
      print('An error occurred during logout: $e');
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.asset(
                      'assets/images/bvmlogo.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BIRLA VISHVAKARMA MAHAVIDYALAYA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                            Text(
                              'Username: ${widget.username}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Developer: Vraj Upadhyay - 22IT402',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Add Course'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/add_course',
                    arguments: {'username': widget.username});
              },
            ),
            ListTile(
              title: Text('View Courses'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/view_courses',
                    arguments: {'username': widget.username});
              },
            ),
            ListTile(
              title: Text('Take/View Attendance'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/attendance',
                    arguments: {
                      'username': widget.username,
                      'password': widget.password
                    });
              },
            ),
            // ListTile(
            //   title: Text('Take/View Extra-Lecture'),
            //   onTap: () {
            //     Navigator.of(context).pop();
            //     Navigator.of(context).pushReplacementNamed('/extraLecture',
            //         arguments: {
            //           'username': widget.username,
            //           'password': widget.password
            //         });
            //   },
            // ),
            ListTile(
              title: Text('Generate Report'),
              onTap: () {
                Navigator.of(context).pushNamed('/generate_attendance_report',
                    arguments: {'username': widget.username});
              },
            ),
            ListTile(
              title: Text('Overall Attendance'),
              onTap: () {
                Navigator.of(context).pushNamed('/monthly_attendance',
                    arguments: {'username': widget.username});
              },
            ),
            ListTile(
              title: Text('Import Student'),
              onTap: () {
                Navigator.of(context).pushNamed('/importStudentByCourse',
                    arguments: {'username': widget.username});
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.of(context).pushNamed('/faculty-profile',
                    arguments: {
                      'username': widget.username,
                      'password': widget.password
                    });
              },
            ),
            // Logout
            ListTile(
              title: Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                logout();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Enrolled Courses Count
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  _showEnrolledCourses(context);
                },
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${enrolledCourses.length}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Total Courses',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Today's Lectures
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Lectures:',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  // List of today's lectures
                  ...todayData.map((today) {
                    return ListTile(
                      title: Text(
                        '${today['TodayLecture']} ${(today['ClassType'] == 'Laboratory' || today['ClassType'] == 'Tutorial') ? '- ${today['Batch']}' : ''}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        today['TodayTime'],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        child: Center(
          child: Text(
            '© BIRLA VISHVAKARMA MAHAVIDHYALAYA-2024',
            style: TextStyle(fontSize: 12.0),
          ),
        ),
        height: 40.0,
        color: Colors.grey[200],
      ),
    );
  }

  // Method to show enrolled courses in a bottom sheet
  void _showEnrolledCourses(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enrolled Courses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                // List of enrolled courses
                ...enrolledCourses.map((course) {
                  return ListTile(
                    title: Text(course['course_name']),
                    subtitle: Text(course['course_id']),
                    // Add onTap handler for course item if needed
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
