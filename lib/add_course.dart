import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddCourseScreen extends StatefulWidget {
  final String username;

  AddCourseScreen({required this.username});

  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  String? courseId;
  String? courseName;
  String? department;
  DateTime? startDate;
  DateTime? endDate;
  String? classType = 'Lecture';
  String? batch = 'ALL';
  String? sem;
  // Map to store selected times for each day
  Map<String, TimeOfDay?> selectedTimes = {
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
  };

  // Custom widget for time selection
  Widget buildTimePicker(String day) {
    return Row(
      children: [
        Text('$day Time: '),
        ElevatedButton(
          onPressed: () async {
            TimeOfDay? selectedTime = await showTimePicker(
              context: context,
              initialTime: selectedTimes[day] ?? TimeOfDay.now(),
            );
            if (selectedTime != null) {
              setState(() {
                selectedTimes[day] = selectedTime;
              });
            }
          },
          child: Text(
            selectedTimes[day] != null
                ? selectedTimes[day]!.format(context)
                : 'Select Time',
          ),
        ),
      ],
    );
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final formattedTime =
        DateFormat.Hm().format(dateTime); // You can use any desired time format
    return formattedTime;
  }

  TextEditingController courseIdController = TextEditingController();
  TextEditingController courseNameController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController batchController = TextEditingController();
  TextEditingController semController = TextEditingController();

  Future<void> _addCourse() async {
    if (_formKey.currentState!.validate()) {
      // Convert selectedTimes to a map of day-to-time strings
      final Map<String, String?> timesAsStrings = {};
      selectedTimes.forEach((day, time) {
        if (time != null) {
          timesAsStrings[day] = formatTimeOfDay(time);
        }
      });

      final Uri url = Uri.parse(
          'https://web.ieeebvm.in/bvm_attendance/course/createCourse.php'); // Replace with your API endpoint

      final Map<String, dynamic> courseData = {
        'username': widget.username,
        'courseId': courseId,
        'courseName': courseName,
        'startDate': startDate?.toLocal().toString(),
        'endDate': endDate?.toLocal().toString(),
        'department': department,
        'classType': classType,
        'batch': batch,
        'sem': sem, // Add the 'sem' field to the request
        'selectedTimes': timesAsStrings,
      };

      final http.Response response = await http.post(
        url,
        body: json.encode(courseData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // Course added successfully
        _showSnackBar('Course added successfully',
            backgroundColor: Colors.green);
        _clearFormFields();
      } else {
        // Course addition failed
        _showSnackBar('Course addition failed', backgroundColor: Colors.red);
      }
    }
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      backgroundColor: backgroundColor, // Set the background color to green
    ));
  }

  void _clearFormFields() {
    courseIdController.clear();
    courseNameController.clear();
    departmentController.clear();
    batchController.clear();
    semController.clear();
    setState(() {
      startDate = null;
      endDate = null;
      classType = null;
      batch = null;
      sem = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: courseIdController,
                decoration: InputDecoration(
                  labelText: 'Course ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course ID';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    courseId = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: courseNameController,
                decoration: InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    courseName = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: departmentController,
                decoration: InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the department';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    department = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: semController,
                decoration: InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the semester';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    sem = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: classType,
                onChanged: (value) {
                  setState(() {
                    classType = value;
                  });
                },
                items: ['Lecture', 'Laboratory', 'Tutorial']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Class Type',
                  border: OutlineInputBorder(),
                ),
              ),
              // / Batch field (shown for Laboratory and Tutorial)
              if (classType != 'Lecture')
                TextFormField(
                  controller: batchController,
                  decoration: InputDecoration(
                    labelText: 'Batch',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the batch';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      batch = value;
                    });
                  },
                ),
              SizedBox(height: 16.0),
              ListTile(
                title: Text(
                  'Start Date: ${startDate != null ? startDate!.toLocal().toString().split(' ')[0] : 'Choose a date'}',
                ),
                onTap: () async {
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null && selectedDate != startDate) {
                    setState(() {
                      startDate = selectedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 16.0),
              ListTile(
                title: Text(
                  'End Date: ${endDate != null ? endDate!.toLocal().toString().split(' ')[0] : 'Choose a date'}',
                ),
                onTap: () async {
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null && selectedDate != endDate) {
                    setState(() {
                      endDate = selectedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 16.0),
              Text('Select Weekly Days and Times:'),
              for (String day in selectedTimes.keys)
                Column(
                  children: [
                    CheckboxListTile(
                      title: Text(day),
                      value: selectedTimes[day] != null,
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            // Show time picker if the checkbox is checked
                            _showTimePicker(day);
                          } else {
                            selectedTimes[day] = null;
                          }
                        });
                      },
                    ),
                    if (selectedTimes[day] != null) buildTimePicker(day),
                    SizedBox(height: 8.0),
                  ],
                ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _addCourse();
                },
                child: Text('Add Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTimePicker(String day) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: selectedTimes[day] ?? TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        selectedTimes[day] = selectedTime;
      });
    }
  }
}
