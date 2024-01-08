import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditAttendancePage extends StatefulWidget {
  final String username;
  final String course_id;
  final String currentDate;

  EditAttendancePage({
    required this.username,
    required this.course_id,
    required this.currentDate,
  });

  @override
  _EditAttendancePageState createState() => _EditAttendancePageState();
}

class _EditAttendancePageState extends State<EditAttendancePage> {
  List<dynamic> attendanceData = [];

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    final Uri url = Uri.parse(
        'https://web.ieeebvm.in/bvm_attendance/attendance/getAttendance.php?date=${widget.currentDate}&course_id=${widget.course_id}&username=${widget.username}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData is List) {
          setState(() {
            attendanceData = jsonData;
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

  // Function to show a snackbar with a message
  void showAttendanceUpdatedSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Adjust the duration as needed
      ),
    );
  }

 void toggleAttendance(int index) async {
  final data = attendanceData[index];
  final studentUID = data['id'];

  // Assuming your backend API can toggle attendance for a student
  final Uri toggleUrl = Uri.parse(
      'https://web.ieeebvm.in/bvm_attendance/attendance/updateStudentAttendance.php');

  try {
    final response = await http.put(
      toggleUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'course_id': widget.course_id,
        'currentDate': widget.currentDate,
        'studentUID': studentUID,
      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      // Successfully toggled attendance, update the UI
      setState(() {
        // Toggle the attendance status locally in the UI
        attendanceData[index]['status'] =
            attendanceData[index]['status'] == 'Present'
                ? 'Absent'
                : 'Present';
      });
      showAttendanceUpdatedSnackbar(
          context, 'Attendance updated successfully');
    } else {
      showAttendanceUpdatedSnackbar(
          context, 'Error toggling attendance: ${response.statusCode}');
      print('Error toggling attendance: ${response.statusCode}');
    }
  } catch (e) {
    print('Error toggling attendance: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Attendance'),
      ),
      body: ListView.builder(
        itemCount: attendanceData.length,
        itemBuilder: (context, index) {
          final data = attendanceData[index];
          final status = data['status'];
          return ListTile(
            title: Text(data['uid'].toString()),
            subtitle: Text(data['fullname'].toString()),
            trailing: GestureDetector(
              onTap: () {
                // Toggle attendance when tapped
                toggleAttendance(index);
              },
              child: Container(
                width: 60,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: status == 'Present' ? Colors.green : Colors.red,
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
