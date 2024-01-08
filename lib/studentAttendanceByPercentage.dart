import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// void main() {
//   runApp(MaterialApp(
//     home: StudentAttendancePercentage(
//       course_id: 'your_course_id',
//       username: 'your_username',
//     ),
//   ));
// }

class StudentAttendancePercentage extends StatefulWidget {
  final String course_id;
  final String username;
  final String courseId;
  final String courseName;

  StudentAttendancePercentage(
      {required this.course_id,
      required this.username,
      required this.courseId,
      required this.courseName});

  @override
  _StudentAttendancePercentageState createState() =>
      _StudentAttendancePercentageState();
}

class _StudentAttendancePercentageState
    extends State<StudentAttendancePercentage> {
  List<StudentData> studentDataList = [];
  double selectedCriteria = 75.0; // Default criteria value

  @override
  void initState() {
    super.initState();
    // Call the function to fetch student attendance data
    fetchStudentAttendance();
  }

  Future<void> fetchStudentAttendance() async {
    final Uri url = Uri.parse(
        'https://web.ieeebvm.in/bvm_attendance/attendance/getStudentAttendance.php?course_id=${widget.course_id}&username=${widget.username}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData is List) {
          final List<StudentData> students = jsonData
              .map((studentJson) => StudentData.fromJson(studentJson))
              .toList();

          setState(() {
            studentDataList = students;
          });
        } else {
          print('Student data is null or not a list');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to filter students based on the selected criteria
  void filterStudentsByCriteria() {
    final filteredStudents = studentDataList
        .where((student) => double.parse(student.percentage) < selectedCriteria)
        .toList();

    setState(() {
      studentDataList = filteredStudents;
    });
  }

  // Function to show student details
  void _showStudentDetails(StudentData student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Student Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${student.studentName}'),
              Text('UID: ${student.studentUID}'),
              Text('Contact Number: ${student.ContactNumber}'),
              Text('Email ID: ${student.EmailId}'),
              Text('Course ID: ${widget.courseId}'),
              Text('Course Name: ${widget.courseName}'),
              Text('Percentage: ${student.percentage}%'),
              Text(
                'Present Days: ${student.presentDays}/${student.totalDays}',
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Implement the logic to send an email to the student here
                // You can use packages like 'mailer' for sending emails
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Change the button color
              ),
              child: Text('Send Email'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement the logic to send an SMS to the student here
                // You can use packages like 'flutter_sms' for sending SMS
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Change the button color
              ),
              child: Text('Send SMS'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Change the button color to red
              ),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Information'),
      ),
      body: Column(
        children: [
          // Card for selection and search
          Card(
            margin: EdgeInsets.all(16.0),
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Select Percentage Criteria: '),
                      DropdownButton<double>(
                        value: selectedCriteria,
                        items: [25.0, 50.0, 60.0, 75.0, 90.0, 100.0]
                            .map<DropdownMenuItem<double>>((double value) {
                          return DropdownMenuItem<double>(
                            value: value,
                            child: Text('$value%'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCriteria = value!;
                            filterStudentsByCriteria(); // Filter students
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: studentDataList.length,
              itemBuilder: (context, index) {
                final studentData = studentDataList[index];
                return GestureDetector(
                  onTap: () {
                    _showStudentDetails(studentData);
                  },
                  child: StudentInfoCard(studentData: studentData),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StudentData {
  final String studentUID;
  final String studentName;
  final String percentage;
  final String presentDays;
  final int totalDays;
  final String courseID;
  final String ContactNumber;
  final String EmailId;

  StudentData({
    required this.studentUID,
    required this.studentName,
    required this.percentage,
    required this.presentDays,
    required this.totalDays,
    required this.courseID,
    required this.ContactNumber,
    required this.EmailId,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      studentUID: json['uid'] ?? '',
      studentName: json['fullname'] ?? '',
      percentage: json['percentage_attendance'] ?? '0.0',
      presentDays: json['present_lectures'] ?? '0',
      totalDays: json['total_lectures'] ?? 0,
      courseID: json['course_id'] ?? '',
      ContactNumber: json['contact_number'] ?? 'NA',
      EmailId: json['emailid'] ?? 'NA',
    );
  }
}

class StudentInfoCard extends StatelessWidget {
  final StudentData studentData;

  StudentInfoCard({required this.studentData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16.0),
          title: Text(
            studentData.studentName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.0),
              Text(
                'ID: ${studentData.studentUID}',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(double.parse(studentData.percentage)).toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 2.0),
              Text(
                'Present: ${studentData.presentDays}/${studentData.totalDays}',
                style: TextStyle(fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
