import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'glassmorphic_quiz_ui.dart';
import 'quiz_detail.dart';
import 'teacher_dashboard.dart';
import 'admin_dashboard.dart';
import 'package:http/http.dart' as http;

const String backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:8000');

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ThinkStrike - Glass UI',
      theme: ThemeData(
        scaffoldBackgroundColor: BeigePalette.baseBackground,
      ),
      home: AuthGate(),
    );
  }
}

class RoleSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeigePalette.baseBackground,
      body: Center(
        child: GlassContainer(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('ThinkStrike', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: BeigePalette.textPrimary)),
            SizedBox(height: 12),
            Text('Select your role to continue', style: TextStyle(color: BeigePalette.softBrown)),
            SizedBox(height: 20),
            Row(mainAxisSize: MainAxisSize.min, children: [
              ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentHome())), child: Text('Student')),
              SizedBox(width: 12),
              ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherDashboard())), child: Text('Teacher')),
              SizedBox(width: 12),
              ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDashboard())), child: Text('Admin')),
            ])
          ]),
        ),
      ),
    );
  }
}

// StudentHome (previously QuizLoader)

class AuthGate extends StatefulWidget {
  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? role;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final r = prefs.getString('role');
    if (token != null && r != null) {
      setState(() { role = r; loading = false; });
    } else {
      setState(() { role = null; loading = false; });
    }
  }

  void onLogged() async {
    final prefs = await SharedPreferences.getInstance();
    final r = prefs.getString('role');
    setState(() { role = r; });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(body: Center(child: CircularProgressIndicator()));
    if (role == null) return LoginPage(onLogged: onLogged);
    if (role == 'student') return StudentHome();
    if (role == 'teacher') return TeacherDashboard();
    if (role == 'admin') return AdminUserManagement();
    return RoleSelector();
  }
}

class StudentHome extends StatefulWidget {
  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  List<Map<String, dynamic>> quizzes = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    setState(() { loading = true; error = null; });
    try {
      final resp = await http.get(Uri.parse('$backendUrl/quizzes'));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List;
        quizzes = data.map<Map<String, dynamic>>((q) => {
          'title': q['title'] ?? 'Untitled',
          'description': q['description'] ?? '',
          'difficulty': q['difficulty'] ?? 'Easy',
          'time': q['time'] ?? 10,
          'questions': q['questions'] ?? 5,
          '_id': q['_id'] ?? q['id']
        }).toList();
      } else {
        throw Exception('Backend error: ${resp.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Fetch quizzes failed: $e');
      // fallback to sample data
      quizzes = [
        { 'title': 'Basic Algebra', 'description': 'Linear equations, simplification, and factoring.', 'difficulty': 'Easy', 'time': 12, 'questions': 10, '_id': 'local-1' },
        { 'title': 'World History', 'description': 'Important events from 1500 to present.', 'difficulty': 'Medium', 'time': 20, 'questions': 15, '_id': 'local-2' },
        { 'title': 'Physics Mechanics', 'description': 'Forces, energy, and motion problems.', 'difficulty': 'Hard', 'time': 30, 'questions': 20, '_id': 'local-3' },
      ];
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: BeigePalette.baseBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: BeigePalette.baseBackground,
      appBar: PreferredSize(preferredSize: Size.fromHeight(70), child: GlassHeader(title: 'ThinkStrike', categories: ['All','Math','Science'], onCategorySelected: (c) { if (kDebugMode) print('cat $c'); })),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 920),
          child: AnimatedQuizList(quizzes: quizzes.map((q) => {
            'title': q['title'],
            'description': q['description'],
            'difficulty': q['difficulty'],
            'time': q['time'],
            'questions': q['questions'],
            '_id': q['_id']
          }).toList()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // pull to refresh
          await fetchQuizzes();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
