import 'dart:convert';
import 'package:flutter/material.dart';
import 'glassmorphic_quiz_ui.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'quiz_detail.dart';

const String backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:8000');

class TeacherDashboard extends StatefulWidget {
  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  List<Map<String,dynamic>> quizzes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    setState(() => loading = true);
    try {
      final resp = await http.get(Uri.parse('$backendUrl/quizzes'));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List;
        quizzes = data.map((q) => {
          '_id': q['_id'],
          'title': q['title'],
          'description': q['description'],
          'difficulty': q['difficulty'],
          'time': q['time'],
          'questions': q['questions'],
        }).toList();
      }
    } catch (e) {
      if (kDebugMode) print('teacher fetch error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> generateQuizDialog() async {
    final topicCtrl = TextEditingController();
    final numCtrl = TextEditingController(text: '5');
    final result = await showDialog<Map<String,dynamic>>(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text('Generate Quiz'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: topicCtrl, decoration: InputDecoration(labelText: 'Topic')),
          TextField(controller: numCtrl, decoration: InputDecoration(labelText: 'Number of questions'), keyboardType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(onPressed: () async {
            final topic = topicCtrl.text.trim();
            final n = int.tryParse(numCtrl.text) ?? 5;
            try {
              final resp = await http.post(Uri.parse('$backendUrl/quizzes/generate'), headers: {'Content-Type':'application/json'}, body: json.encode({'topic': topic, 'num_questions': n}));
              if (resp.statusCode == 200) {
                final data = json.decode(resp.body);
                Navigator.pop(ctx, data);
              } else {
                Navigator.pop(ctx, null);
              }
            } catch (e) {
              Navigator.pop(ctx, null);
            }
          }, child: Text('Generate')),
        ],
      );
    });

    if (result != null) {
      // show preview and option to save
      final save = await showDialog<bool>(context: context, builder: (ctx) {
        return AlertDialog(
          title: Text('Preview Quiz'),
          content: SizedBox(width: 400, height: 300, child: SingleChildScrollView(child: Column(children: [
            Text(result['title'] ?? ''),
            SizedBox(height:8),
            Text(result['description'] ?? ''),
            SizedBox(height:8),
            Text('Questions: ${ (result['questions'] as List).length }')
          ]))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Close')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Save')),
          ],
        );
      });

      if (save == true) {
        try {
          final resp = await http.post(Uri.parse('$backendUrl/quizzes'), headers: {'Content-Type':'application/json'}, body: json.encode(result));
          if (resp.statusCode == 200 || resp.statusCode == 201) {
            await fetchQuizzes();
          }
        } catch (e) {
          if (kDebugMode) print('save error: $e');
        }
      }
    }
  }

  Future<void> deleteQuiz(String id) async {
    try {
      final resp = await http.delete(Uri.parse('$backendUrl/quizzes/$id'));
      if (resp.statusCode == 200) {
        await fetchQuizzes();
      }
    } catch (e) { if (kDebugMode) print('delete error: $e'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(70), child: GlassHeader(title: 'Teacher Dashboard', categories: [])),
      body: loading ? Center(child: CircularProgressIndicator()) : Padding(
        padding: EdgeInsets.all(12),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('My Quizzes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: generateQuizDialog, child: Text('Generate Quiz'))
          ]),
          SizedBox(height:12),
          Expanded(child: ListView.separated(itemBuilder: (ctx, idx) {
            final q = quizzes[idx];
            return ListTile(
              title: Text(q['title'] ?? ''),
              subtitle: Text(q['description'] ?? ''),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () {
                  // navigate to edit screen (reusing QuizDetail for simple edit isn't implemented fully)
                }),
                IconButton(icon: Icon(Icons.delete), onPressed: () => deleteQuiz(q['_id'])),
              ]),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizDetailPage(quizId: q['_id'], title: q['title']))),
            );
          }, separatorBuilder: (_,__) => Divider(), itemCount: quizzes.length))
        ]),
      ),
    );
  }
}
