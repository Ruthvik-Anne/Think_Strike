import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TeacherScreen extends StatelessWidget {
  final ApiService api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teacher Dashboard")),
      body: Center(
        child: ElevatedButton(
          child: Text("Generate Quiz Preview"),
          onPressed: () async {
            var quiz = await api.generateQuizPreview("Algebra", "medium", 3);
            print(quiz);
          },
        ),
      ),
    );
  }
}