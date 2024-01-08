import 'package:bvm_attendance_system/GenerateReportPage.dart';
import 'package:bvm_attendance_system/addStudentScreen.dart';
import 'package:bvm_attendance_system/add_course.dart';
import 'package:bvm_attendance_system/attendanceScreen.dart';
import 'package:bvm_attendance_system/extra-lecture/extraAttendaceScreen.dart';
import 'package:bvm_attendance_system/faculty_dashboard.dart';
import 'package:bvm_attendance_system/importStudentByCourse.dart';
import 'package:bvm_attendance_system/overallAttendance.dart';
import 'package:bvm_attendance_system/profile/facultyProfile.dart';
import 'package:bvm_attendance_system/registration_screen.dart';
import 'package:bvm_attendance_system/takeAttendance.dart';
import 'package:bvm_attendance_system/ViewAttendanceDialog.dart';
import 'package:flutter/material.dart';
import 'package:bvm_attendance_system/login_screen.dart' as login;
import 'package:bvm_attendance_system/view_courses.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BVM Attendance System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Define the initial route to the login screen
      initialRoute: '/login',
      routes: {
        // Define named routes for your screens
        '/login': (context) => const login.LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final username = args['username'];
          final password = args['password'];
          return DashboardScreen(
            username: username,
            password: password,
          ); // Pass the username to DashboardScreen
        },
        '/add_course': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final username = args['username'];
          return AddCourseScreen(
            username: username,
          ); // Pass the username to AddCourseScreen
        },
        '/view_courses': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final username = args?['username'];
          return ViewCoursesScreen(
            username: username,
          ); // Pass the username to ViewCourseScreen
        },
        '/add_student': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final username = args?['username'];
          return AddStudentScreen(
            username: username,
            courseId: '',
            batch: '',
            classType: '',
          );
          // Add more routes as needed for other screens
        },
        '/attendance': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final username = args?['username'];
          final password = args?['password'];
          return AttendancePage(
            username: username,
            password: password,
          );
        },
        '/take_attendance': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final username = args?['username'];
          final courseId = args?['course_id'];
          final courseName = args?['course_name'];
          final batch = args?['batch'];
          final Id = args?['id'];
          return TakeAttendancePage(
            username: username,
            courseId: courseId,
            courseName: courseName,
            batch: batch,
            course: {},
            Id: Id,
          );
        },
        '/viewAttendance': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return AttendanceViewerPage(
            username: '',
            initialDate: '',
            course_id: '',
          );
        },
        '/generate_attendance_report': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final username = args?['username'];
          return GenerateReportPage(
            username: username,
          );
        },
        '/monthly_attendance': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final username = args?['username'];
          return MonthlyAttendance(
            username: username,
          );
        },
        '/importStudentByCourse': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final username = args?['username'];
          return ImportStudentByCourse(
            username: username,
          );
        },
        '/extraLacture': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final username = args?['username'];
          final password = args?['password'];
          return ExtraAttendancePage(
            username: username,
            password: password,
          );
        },
        '/faculty-profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final username = args?['username'];
          final password = args?['password'];
          return FacultyDetailsPage(
            username: username,
            password: password,
          );
        },
      },
    );
  }
}
