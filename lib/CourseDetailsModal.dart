import 'package:flutter/material.dart';

class CustomPopupDialog extends StatelessWidget {
  final String title;
  final String content;
  final String username;

  CustomPopupDialog({
    required this.title,
    required this.content,
    required this.courseId,
    required this.courseName,
    required this.department,
    required this.startDate,
    required this.endDate,
    required this.username,
    required this.selectedTimes,
    required this.classType, required this.batch,
  });
  // final String title;
  final String courseId;
  final String courseName;
  final String department;
  final String startDate;
  final String endDate;
  final String selectedTimes;
  final String classType;
  final String batch;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Course ID: $courseId'),
          Text('Course Name: $courseName'),
          Text('Department: $department'),
          Text('Start Date: $startDate'),
          Text('End Date: $endDate'),
          Text('Selected Days: $selectedTimes'),
          Text('Class Type: $classType'),
          Text('Batch: $batch'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
