import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "http://localhost:8000";

Future<Map<String, dynamic>> previewQuiz(String topic, String difficulty, int numQuestions) async {
  final response = await http.post(
    Uri.parse('$baseUrl/teacher/quiz/preview'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'topic': topic,
      'difficulty': difficulty,
      'num_questions': numQuestions,
    }),
  );
  return json.decode(response.body);
}

Future<Map<String, dynamic>> generateQuiz(String topic, String difficulty, int numQuestions) async {
  final response = await http.post(
    Uri.parse('$baseUrl/teacher/quiz/generate'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'topic': topic,
      'difficulty': difficulty,
      'num_questions': numQuestions,
    }),
  );
  return json.decode(response.body);
}
