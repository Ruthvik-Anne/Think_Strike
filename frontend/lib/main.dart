import 'package:flutter/material.dart';
import 'screens/teacher_screen.dart';
import 'screens/student_screen.dart';
import 'screens/admin_screen.dart';

void main() {
  runApp(ThinkStrikeApp());
}

class ThinkStrikeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThinkStrike',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RoleSelector(),
    );
  }
}

class RoleSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ThinkStrike")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(child: Text("Teacher"), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherScreen()));
            }),
            ElevatedButton(child: Text("Student"), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => StudentScreen()));
            }),
            ElevatedButton(child: Text("Admin"), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminScreen()));
            }),
          ],
        ),
      ),
    );
  }
}