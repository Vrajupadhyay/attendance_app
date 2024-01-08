import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class GenerateReportPage extends StatefulWidget {
  final String username;

  GenerateReportPage({required this.username});

  @override
  _GenerateReportPageState createState() => _GenerateReportPageState();
}

class _GenerateReportPageState extends State<GenerateReportPage> {
  List<dynamic> courseList = [];
  int selectedMonth = DateTime.now().month;
  int selectedPercentage = 0; // Default percentage
  bool isLoading = false;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final Uri url = Uri.parse(
        'https://web.ieeebvm.in/bvm_attendance/course/getCourseByUsername.php?username=${widget.username}');

    try {
      setState(() {
        isLoading = true; // Set loading to true when starting the request
      });
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is List) {
          setState(() {
            courseList = jsonData;
          });
        } else {
          showError('Data is not a list');
        }
      } else {
        showError('Error: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error: $e');
    } finally {
      setState(() {
        isLoading = false; // Set loading to false when the request is complete
      });
    }
  }

 Future<void> generateReportByMonth(String course_id, String selectedMonth) async {
  final String baseUrl = 'https://web.ieeebvm.in/bvm_attendance';
  final String url = '$baseUrl/attendance/generateAttendanceReportMonthly.php?course_id=$course_id&username=${widget.username}&selectedMonth=$selectedMonth';

  try {
    showLoading();
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Save the file locally
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/attendance_report_monthly.xlsx');
      await file.writeAsBytes(response.bodyBytes);

      // Open the local file using open_file package
      await OpenFile.open(file.path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    } else {
      showError('Failed to download report. Status code: ${response.statusCode}\n${response.body}');
    }
  } catch (e) {
    showError('Error downloading report: $e');
  } finally {
    hideLoading();
  }
}

  Future<void> generateReportByPercentage(String course_id, int percentage) async {
    final String baseUrl = 'https://web.ieeebvm.in/bvm_attendance';
    final String url = '$baseUrl/attendance/generateAttendanceReportPercentageFilter.php?course_id=$course_id&username=${widget.username}&percentage=$percentage';

    try {
      showLoading();
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Save the file locally
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/attendance_report_percentage.xlsx');
        await file.writeAsBytes(response.bodyBytes);

        // Open the local file using open_file package
        await OpenFile.open(file.path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      } else {
        showError('Failed to download report. Status code: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      showError('Error downloading report: $e');
    } finally {
      hideLoading();
    }
  }

  void showLoading() {
    setState(() {
      isLoading = true;
      errorText = '';
    });
  }

  void hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  void showError(String message) {
    setState(() {
      errorText = message;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  // Check and request permissions
  Future<void> requestPermissions() async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        // Permission granted, you can open files now
      } else {
        // Permission denied
      }
    } else {
      // Permission already granted
    }
  }

  
  Future<void> generateReportBySEM(String course_id) async {
    final String baseUrl = 'https://web.ieeebvm.in/bvm_attendance';
    final String url =
        '$baseUrl/attendance/generateAttendanceReport.php?course_id=${course_id}&username=${widget.username}';

    try {
      setState(() {
        isLoading = true; // Set loading to true when starting the request
        errorText = '';
      });

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Save the file locally
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/attendance_report.xlsx');
        await file.writeAsBytes(response.bodyBytes);

        // Open the local file using open_file package
        await OpenFile.open(file.path);
      } else {
        showError('Failed to download report. Status code: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error downloading report: $e');
    } finally {
      setState(() {
        isLoading = false; // Set loading to false when the request is complete
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Report'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            255, 103, 181, 214), // Background color
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                      padding: EdgeInsets.all(16.0),
                      margin: EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Automatic Generate:',
                            style:
                                TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Select Month:',
                            style:
                                TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          MonthPickerWidget(
                            selectedMonth: selectedMonth,
                            onMonthSelected: (int? month) {
                              setState(() {
                                selectedMonth = month!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            255, 103, 181, 214), // Background color
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                      padding: EdgeInsets.all(16.0),
                      margin: EdgeInsets.only(bottom: 13.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manual Percentage Criteria:',
                            style:
                                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<int>(
                            value: selectedPercentage,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedPercentage = newValue!;
                              });
                            },
                            items: [0, 25, 40, 50, 60, 75, 80].map((int percentage) {
                              return DropdownMenuItem<int>(
                                value: percentage,
                                child: Text('$percentage%'),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),
                    Column(
                      children: courseList.map((course) {
                        final classType = course['classType'];
                        Color backgroundColor;
                        if (classType == 'Lecture') {
                          backgroundColor = Colors.blue;
                        } else if (classType == 'Laboratory') {
                          backgroundColor = Colors.green;
                        } else {
                          backgroundColor = Color.fromARGB(
                              255, 230, 224, 224); // Default background color
                        }
                        return Card(
                          elevation: 3.0,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          color: backgroundColor, // Set background color here
                          child: ListTile(
                            title: Text(
                                '${course['course_id']} - ${course['course_name']}'),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        'Generate Report for ${course['course_name']}'),
                                    content: Text(
                                        'Are you sure you want to generate a report for this course?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Monthly Generate'),
                                        onPressed: () {
                                          Navigator.of(context).pop();

                                          if (selectedMonth != null) {
                                            generateReportByMonth(
                                              course['id'].toString(),
                                              selectedMonth.toString(),
                                            );
                                          } else {
                                            // Handle the case where selectedMonth is null
                                            print('Selected month is null');
                                            // You can display an error message or handle it as needed
                                          }
                                        },
                                      ),
                                      TextButton(
                                        child: Text('All SEM Generate'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          try {
                                            generateReportBySEM(
                                                course['id'].toString());
                                          } catch (error) {
                                            print('Error: $error');
                                          }
                                        },
                                      ),
                                      Visibility(
                                        visible: selectedPercentage >
                                            0, // Show the button if a percentage is selected
                                        child: TextButton(
                                          child: Text('Manual Attendance'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            generateReportByPercentage(
                                              course['id'].toString(),
                                              selectedPercentage,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    // Show loader when isLoading is true
                    if (isLoading)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: CircularProgressIndicator(
                          strokeWidth: 4.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                    // Show error message
                    if (errorText.isNotEmpty)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          errorText,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
            ),
          ),
          ],
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

class MonthPickerWidget extends StatelessWidget {
  final int selectedMonth;
  final void Function(int) onMonthSelected;

  MonthPickerWidget({
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: selectedMonth,
      onChanged: (int? newValue) {
        if (newValue != null) {
          onMonthSelected(newValue);
        } else {
          // Handle the case where the selected month is null
          print('Selected month is null');
        }
      },
      items: List<DropdownMenuItem<int>>.generate(
        12,
        (int index) {
          return DropdownMenuItem<int>(
            value: index + 1,
            child: Text('${index + 1}'),
          );
        },
      ),
    );
  }
}
