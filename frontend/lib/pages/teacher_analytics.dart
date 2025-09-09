import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class TeacherAnalyticsPage extends StatefulWidget {
  const TeacherAnalyticsPage({super.key});
  @override
  State<TeacherAnalyticsPage> createState() => _TeacherAnalyticsPageState();
}

class _TeacherAnalyticsPageState extends State<TeacherAnalyticsPage> {
  final _api = ApiService();
  Map<String, dynamic>? _data;
  bool _loading = false;

  Future<void> _load(String teacherId) async {
    setState(()=> _loading = true);
    final res = await _api.get('/analytics/teacher/$teacherId');
    setState(()=> _loading = false);
    if (res.statusCode == 200) setState(()=> _data = jsonDecode(res.body));
  }

  @override
  void initState(){
    super.initState();
    Future.microtask(() async {
      // fetch /auth/me to get id
      final me = await _api.get('/auth/me');
      if (me.statusCode == 200){
        final id = (jsonDecode(me.body) as Map<String,dynamic>)['id'] as String;
        await _load(id);
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Analytics')),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        _data == null ? const Center(child: Text('No data')) :
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Average Score per Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(child: BarChart(BarChartData(
              barGroups: List.generate((_data!['quizzes'] as List).length, (i){
                final q = _data!['quizzes'][i];
                final avg = (q['avg_score'] ?? 0.0) * 1.0
                  / (q['avg_total'] == 0 ? 1.0 : q['avg_total']);
                return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: avg.isFinite? avg*100 : 0)]);
              }),
              titlesData: FlTitlesData(show: false),
            ))),
          ]),
        ),
    );
  }
}
