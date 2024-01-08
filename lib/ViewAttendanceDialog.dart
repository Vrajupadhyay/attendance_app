import 'package:bvm_attendance_system/EditAttendance.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class AttendanceViewerPage extends StatefulWidget {
  final String username;
  final String initialDate;
  final String course_id;

  AttendanceViewerPage({
    required this.username,
    required this.initialDate,
    required this.course_id,
  });

  @override
  _AttendanceViewerPageState createState() => _AttendanceViewerPageState();
}

class _AttendanceViewerPageState extends State<AttendanceViewerPage> {
  String currentDate = "";
  List<dynamic> attendanceData = [];

  @override
  void initState() {
    super.initState();
    currentDate = widget.initialDate;
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    final Uri url = Uri.parse(
        'https://web.ieeebvm.in/bvm_attendance/attendance/getAttendance.php?course_id=${widget.course_id}&date=${currentDate}&username=${widget.username}');

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

Future<void> showDatePickerDialog() async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.parse(currentDate),
    firstDate: DateTime(2020),
    lastDate: DateTime(2101),
  );

  if (pickedDate != null) {
    setState(() {
      currentDate = pickedDate!.toLocal().toIso8601String().split('T')[0];
      attendanceData.clear();
    });
    fetchAttendanceData();
  }
}


  void changeDate(int daysToAdd) {
    final DateTime currentDateObj = DateTime.parse(currentDate);
    final newDateObj = currentDateObj.add(Duration(days: daysToAdd));
    setState(() {
      currentDate = newDateObj.toLocal().toIso8601String().split('T')[0];
      attendanceData.clear();
    });
    fetchAttendanceData();
  }

  void deleteAttendance() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Attendance'),
      content: Text('Are you sure you want to delete attendance?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            try {
              final Uri url = Uri.parse(
                  'https://web.ieeebvm.in/bvm_attendance/attendance/deleteAttendanceByDate.php');

              final response = await http.put(
                url,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'course_id': widget.course_id,
                  'date': currentDate,
                  'username': widget.username,
                }),
              );
              print(response.body);
              if (response.statusCode == 200) {
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                print('Error: ${response.statusCode}');
              }
            } catch (e) {
              print('Error: $e');
            }
          },
          child: Text('Delete'),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Attendance'),
      ),
      body: Column(
        children: <Widget>[
           Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_left,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    changeDate(-1);
                  },
                ),
                Text(
                  DateFormat('MMMM dd, yyyy')
                      .format(DateTime.parse(currentDate)),
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_right,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    changeDate(1);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                  ),
                  onPressed: showDatePickerDialog,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: attendanceData.length,
              itemBuilder: (context, index) {
                final data = attendanceData[index];
                final status = data['status'];
                return ListTile(
                  title: Text(data['uid'].toString(),
                      style: TextStyle(color: Colors.blue)),
                  subtitle: Text(
                    data['fullname'].toString(),
                  ),
                  trailing: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: status == 'Present' ? Colors.green : Colors.red,
                    ),
                    child: Text(
                      status == 'Present' ? 'P' : 'A',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAttendancePage(
                        username: widget.username,
                        course_id: widget.course_id.toString(),
                        currentDate: currentDate,
                      ),
                    ),
                  );
                  // Handle taking attendance for this course
                  // You can add your logic here
                },
                child: Text('Edit Attendance'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: deleteAttendance,
                child: Text('Delete Attendance'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// void main() => runApp(MaterialApp(
//       home: AttendanceViewerPage(
//         username: 'Vraj12', // Replace with the actual username
//         initialDate: '2024-09-28', // Replace with the initial date
//         course_id: '5', // Replace with the actual course ID
//       ),
//     ));
