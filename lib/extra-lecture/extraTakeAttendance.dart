import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ExtraTakeAttendancePage extends StatefulWidget {
  final String username;
  final String Id;
  final String courseId;
  final String courseName;

  ExtraTakeAttendancePage({
    required this.username,
    required this.Id,
    required this.courseId,
    required this.courseName,
    required Map course,
  });

  @override
  _ExtraTakeAttendancePageState createState() =>
      _ExtraTakeAttendancePageState();
}

class _ExtraTakeAttendancePageState extends State<ExtraTakeAttendancePage> {
  List<dynamic> students = [];
  List<bool> attendanceStatus = [];
  DateTime selectedDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final Uri url = Uri.parse(
        'https://web.ieeebvm.in/bvm_attendance/student/getStudentByCourseId.php?course_id=${widget.courseId}&username=${widget.username}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData is List) {
          setState(() {
            students = jsonData;
            // Initialize attendance status as true (Present) for all students
            attendanceStatus = List.generate(students.length, (_) => true);
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

  Future<void> saveAttendanceData() async {
    final Uri apiUrl = Uri.parse(
        'https://web.ieeebvm.in/bvm_attendance/attendance/extraAttendance/markExtraAttendance.php'); // Replace with your API endpoint

    // Create a list of attendance records
    final List<Map<String, dynamic>> attendanceRecords = [];

    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final Map<String, dynamic> record = {
        'student_id': student['id'], // Add student_id
        'status': attendanceStatus[i] ? 'Present' : 'Absent',
      };
      attendanceRecords.add(record);
    }

    final Map<String, dynamic> data = {
      'id': widget.Id,
      'username': widget.username,
      'date': dateFormat.format(selectedDate),
      'attendanceData': attendanceRecords,
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Attendance data saved successfully'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Attendance data not saved || Error: ${response.statusCode}'),
        ));
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Course Name: ${widget.courseName}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Course ID: ${widget.courseId}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date: ${dateFormat.format(selectedDate)}',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return StudentAttendanceTile(
                    student: student,
                    status: attendanceStatus[index],
                    onTap: () {
                      setState(() {
                        attendanceStatus[index] = !attendanceStatus[index];
                      });
                    },
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5.0),
              width: double.infinity, // Makes the button span the full width
              child: ElevatedButton(
                onPressed: () {
                  saveAttendanceData();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Background color of the button
                  onPrimary: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10.0), // Adjust the radius as needed
                  ),
                ),
                child: Text('Save Attendance'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class StudentAttendanceTile extends StatelessWidget {
  final dynamic student;
  final bool status;
  final Function onTap;

  StudentAttendanceTile({
    required this.student,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        student['uid'],
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
      subtitle: Text(student['fullname']),
      tileColor: status ? Colors.white : null,
      shape: status
          ? null
          : RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10.0), // Adjust the radius as needed
              side: BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
      trailing: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: status ? Colors.green : Colors.red,
          ),
          child: Text(
            status ? 'P' : 'A',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
