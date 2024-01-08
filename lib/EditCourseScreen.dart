import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditCourseScreen extends StatefulWidget {
  final String id;

  EditCourseScreen({required this.id, required courseId});

  @override
  _EditCourseScreenState createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  String? courseId;
  String? courseName;
  String? department;
  DateTime? startDate;
  DateTime? endDate;
  List<String> selectedDays = [];

  late TextEditingController courseIdController;
  late TextEditingController courseNameController;
  late TextEditingController departmentController;
  // late TextEditingController startDateController;
  // late TextEditingController endDateController;

  @override
  void initState() {
    super.initState();
    courseIdController = TextEditingController(text: courseId ?? '');
    courseNameController = TextEditingController(text: courseName ?? '');
    departmentController = TextEditingController(text: department ?? '');
    // startDateController =
    //     TextEditingController(text: startDate?.toString() ?? '');
    // endDateController = TextEditingController(text: endDate?.toString() ?? '');

    fetchData();
  }

  Future<void> fetchData() async {
    final Uri url = Uri.parse(
        'https://web.ieeebvm.in/bvm_attendance/course/viewCourseById.php?id=${widget.id}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData is Map<String, dynamic>) {
          setState(() {
            courseId = jsonData['courseId'];
            courseName = jsonData['courseName'];
            department = jsonData['department'];
            // startDate = DateTime.parse(jsonData['startDate']);
            // endDate = DateTime.parse(jsonData['endDate']);
            final selectedDaysString = jsonData['selectedDays'] ?? '';
            selectedDays = selectedDaysString.split(',');
          });
        } else {
          print('Error: ${response.statusCode}');
          print('Data is null or not a map');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateCourse() async {
    final Uri url = Uri.parse(
        'https://web.ieeebvm.in/bvm_attendance/courses/update/${widget.id}');

    final Map<String, dynamic> courseData = {
      'id': widget.id,
      'courseId': courseId,
      'courseName': courseName,
      'department': department,
      // 'startDate': startDate?.toLocal().toString(),
      // 'endDate': endDate?.toLocal().toString(),
      'selectedDays': selectedDays.join(','), // Include selectedDays
    };

    final http.Response response = await http.put(
      url,
      body: json.encode(courseData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Course updated successfully
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Course updated successfully'),
      ));
    } else {
      // Course update failed
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Course update failed'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: courseIdController,
                decoration: InputDecoration(labelText: 'Course ID'),
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
              TextFormField(
                controller: courseNameController,
                decoration: InputDecoration(labelText: 'Course Name'),
                // initialValue: courseName ?? '',
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
              TextFormField(
                controller: departmentController,
                decoration: InputDecoration(labelText: 'Department'),
                // initialValue: department ?? '',
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
              // TextFormField(
              //   controller: startDateController,
              //   decoration: InputDecoration(labelText: 'Start Date'),
              //   validator: (value) {
              //     // Add validation logic here if needed
              //     return null;
              //   },
              //   onChanged: (value) {
              //     setState(() {
              //       startDate = value
              //           as DateTime?; // Update the startDate when the user types
              //     });
              //   },
              // ),
              // TextFormField(
              //   controller: endDateController,
              //   decoration: InputDecoration(labelText: 'End Date'),
              //   validator: (value) {
              //     // Add validation logic here if needed
              //     return null;
              //   },
              //   onChanged: (value) {
              //     setState(() {
              //       endDate = value
              //           as DateTime?; // Update the endDate when the user types
              //     });
              //   },
              // ),

              Text('Days of the week'),
              CheckboxListTile(
                title: Text('Monday'),
                value: selectedDays.contains('Monday'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedDays.add('Monday');
                    } else {
                      selectedDays.remove('Monday');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Tuesday'),
                value: selectedDays.contains('Tuesday'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedDays.add('Tuesday');
                    } else {
                      selectedDays.remove('Tuesday');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Wednesday'),
                value: selectedDays.contains('Wednesday'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedDays.add('Wednesday');
                    } else {
                      selectedDays.remove('Wednesday');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Thursday'),
                value: selectedDays.contains('Thursday'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedDays.add('Thursday');
                    } else {
                      selectedDays.remove('Thursday');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Friday'),
                value: selectedDays.contains('Friday'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedDays.add('Friday');
                    } else {
                      selectedDays.remove('Friday');
                    }
                  });
                },
              ),
              // Add more CheckboxListTile widgets for other days
              ElevatedButton(
                onPressed: () {
                  _updateCourse();
                },
                child: Text('Update Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
