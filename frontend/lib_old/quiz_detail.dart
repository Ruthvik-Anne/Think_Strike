import 'dart:convert';
import 'package:flutter/material.dart';
import 'glassmorphic_quiz_ui.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

const String backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:8000');

class QuizDetailPage extends StatefulWidget {
  final String quizId;
  final String title;
  const QuizDetailPage({Key? key, required this.quizId, required this.title}) : super(key: key);

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  Map<String, dynamic>? quiz;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchQuiz();
  }

  Future<void> fetchQuiz() async {
    setState(() { loading = true; error = null; });
    try {
      final resp = await http.get(Uri.parse('$backendUrl/quizzes/${widget.quizId}'));
      if (resp.statusCode == 200) {
        quiz = json.decode(resp.body);
      } else {
        error = 'Error ${resp.statusCode}';
      }
    } catch (e) {
      if (kDebugMode) print('fetch quiz error: $e');
      error = e.toString();
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null) return Scaffold(body: Center(child: Text('Error: $error')));
    final questions = List<Map<String, dynamic>>.from(quiz!['questions'] ?? []);
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(70), child: GlassHeader(title: widget.title, categories: [])),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(quiz!['description'] ?? '', style: TextStyle(color: BeigePalette.softBrown)),
            SizedBox(height: 12),
            Text('Time: ${quiz!['time']} minutes • ${questions.length} questions', style: TextStyle(color: BeigePalette.softBrown)),
            SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => TakeQuizPage(quiz: quiz!)));
              },
              child: Text('Start Quiz'),
            )
          ],
        ),
      ),
    );
  }
}

class TakeQuizPage extends StatefulWidget {
  final Map<String, dynamic> quiz;
  const TakeQuizPage({Key? key, required this.quiz}) : super(key: key);

  @override
  _TakeQuizPageState createState() => _TakeQuizPageState();
}

class _TakeQuizPageState extends State<TakeQuizPage> {
  Map<String, String> answers = {};

  @override
  Widget build(BuildContext context) {
    final questions = List<Map<String, dynamic>>.from(widget.quiz['questions'] ?? []);
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(70), child: GlassHeader(title: widget.quiz['title'] ?? 'Quiz', categories: [])),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: questions.length,
        itemBuilder: (context, idx) {
          final q = questions[idx];
          final qid = q['id'] ?? 'q$idx';
          return Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q['question'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ...List<Widget>.from((q['options'] ?? ['A','B','C','D']).map((opt) {
                    return RadioListTile<String>(
                      title: Text(opt),
                      value: opt,
                      groupValue: answers[qid],
                      onChanged: (v) => setState(() => answers[qid] = v!),
                    );
                  }))
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(child: ElevatedButton(onPressed: submit, child: Text('Submit'))),
          ],
        ),
      ),
    );
  }

  Future<void> submit() async {
    final quizId = widget.quiz['_id'] ?? widget.quiz['id'];
    try {
      final resp = await http.post(Uri.parse('$backendUrl/quizzes/$quizId/submit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(answers));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizResultPage(result: data)));
      } else {
        if (kDebugMode) print('submit failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      if (kDebugMode) print('submit error: $e');
    }
  }
}

class QuizResultPage extends StatelessWidget {
  final Map<String, dynamic> result;
  const QuizResultPage({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(70), child: GlassHeader(title: 'Results', categories: [])),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(result['summary'] ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: List<Widget>.from((result['mistakes'] ?? []).map<Widget>((m) {
                  return Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Q: ${m['question_id']}', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Expected: ${m['expected']}'),
                    Text('Given: ${m['given']}'),
                    SizedBox(height: 6),
                    Text(m['explanation'] ?? '')
                  ])));
                })),
              ),
            )
          ],
        ),
      ),
    );
  }
}
