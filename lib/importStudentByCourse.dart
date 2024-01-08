import 'dart:io';
import 'dart:typed_data';

import 'package:bvm_attendance_system/CourseDetailsModal.dart';
import 'package:bvm_attendance_system/EditCourseScreen.dart';
import 'package:bvm_attendance_system/addStudentScreen.dart';
import 'package:bvm_attendance_system/viewStudentScreen.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class ImportStudentByCourse extends StatefulWidget {
  final String username;

  ImportStudentByCourse({required this.username});

  @override
  _ImportStudentByCourseState createState() => _ImportStudentByCourseState();
}

class _ImportStudentByCourseState extends State<ImportStudentByCourse> {
  List<dynamic> courses = [];
  String? selectedCourseId;
  String? selectedClassType;
  String? selectedBatch;
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

  Future<List<Map<String, dynamic>>> _parseExcelFile(PlatformFile? file) async {
    if (file == null) {
      _showErrorDialog('Error', 'No file selected.');
      return [];
    }

    try {
      if (file.path == null) {
        _showErrorDialog('Error', 'File path is null.');
        return [];
      }

      final File excelFile = File(file.path!);

      if (!excelFile.existsSync()) {
        _showErrorDialog('Error', 'File does not exist.');
        return [];
      }

      final Uint8List bytes = await excelFile.readAsBytes();

      final excel = Excel.decodeBytes(bytes);

      final table = excel.tables[excel.tables.keys.first];

      if (table == null) {
        _showErrorDialog('Error', 'No data found in the Excel file.');
        return [];
      }

// Extract headers from the first row of the table
      final headers = table.row(0);
      final dataRows = table.rows.toList();

      final List<Map<String, dynamic>> studentData = [];

      for (int i = 1; i < dataRows.length; i++) {
        final row = dataRows[i];
        if (row.length == headers.length) {
          Map<String, dynamic> student = {};
          for (int j = 0; j < headers.length; j++) {
            final headerValue =
                headers[j]?.value.toString() ?? ''; // Extract the header value
            final cellValue =
                row[j]?.value.toString() ?? ''; // Extract the cell value
            student[headerValue] = cellValue;
          }
          studentData.add(student);
        }
      }

      // print('Parsed student data: $studentData'); // Debug: Print parsed data.

      return studentData;
    } catch (e) {
      _showErrorDialog('Error', 'Error parsing the Excel file: $e');
      return [];
    }
  }

  Future<void> uploadExcelFile(PlatformFile? file) async {
  final studentData = await _parseExcelFile(file);

  if (selectedCourseId == null) {
    _showErrorDialog('Error', 'Please select a course before uploading.');
    return;
  }

  final Uri uploadUrl = Uri.parse(
      'https://web.ieeebvm.in/bvm_attendance/student/importStudentByExcel.php');
  final username = widget.username;

  try {
    final specificData = studentData.map((student) {
      return {
        'fullname': student['fullname'],
        'uid': student['uid'],
        'department': student['department'],
        'currentSem': student['currentSem'],
      };
    }).toList();

    if (selectedCourseId == null || username.isEmpty || selectedClassType == null || selectedBatch == null) {
      _showErrorDialog('Error', 'Invalid data. Please check your selections.');
      return;
    }

    final jsonData = {
      'courseId': selectedCourseId,
      'username': username,
      'classType': selectedClassType,
      'batch': selectedBatch,
      'data': specificData,
    };

    // print('Uploading student data: $jsonData');
    final response = await http.post(
      uploadUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(jsonData)
    );

    if (response.statusCode == 200) {
      _showSuccessDialog('Success', 'Student data uploaded successfully.');
    } else {
      _showErrorDialog('Error',
          'Student data upload failed with status code: ${response.statusCode}, ${response.body}');
        
        // print(response.body);
    }
  } catch (e) {
    _showErrorDialog('Error', 'Error uploading student data: $e');
  }
}


  void downloadExcelTemplate() async {
    final String excelUrl =
        'https://docs.google.com/spreadsheets/d/1zQWk2B1edsn3Mk8tt4buKjtWoctS-z0I/edit?usp=sharing&ouid=102223410660857298427&rtpof=true&sd=true'; // Replace with the actual URL of your Excel file

    try {
      if (await canLaunch(excelUrl)) {
        await launch(excelUrl);
      } else {
        print('Could not launch $excelUrl');
      }
    } catch (e) {
      print('Error downloading Excel file: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

// Function to download and open the Excel template
  Future<void> downloadAndOpenExcelTemplate() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Student'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: courses.length,
          itemBuilder: (BuildContext context, int index) {
            final course = courses[index];
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text('Course Name: ${course['course_name']} '),
                subtitle: Text('${course['classType']} - ${course['batch']}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCourseId = course['course_id'].toString();
                      selectedClassType = course['classType'];
                      selectedBatch = course['batch'];
                    });
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.file_download),
                                title: Text('Download Excel Template'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  downloadExcelTemplate();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.upload_file),
                                title: Text('Upload Excel File'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['xlsx', 'xls', 'csv'],
                                  ).then((file) {
                                    uploadExcelFile(file?.files.first);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text('Import'),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        child: Center(
          child: Text(
            '© BIRLA VISHVAKARMA MAHAVIDHYALAYA-2024',
            style: TextStyle(fontSize: 12.0),
          ),
        ),
        height: 50.0,
        color: Colors.grey[200],
      ),
    );
  }
}
