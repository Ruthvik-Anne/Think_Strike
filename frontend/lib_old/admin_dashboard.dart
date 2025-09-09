import 'package:flutter/material.dart';
import 'glassmorphic_quiz_ui.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(70), child: GlassHeader(title: 'Admin Dashboard', categories: [])),
      body: Center(child: Text('Admin tools: user management, analytics (coming soon)', style: TextStyle(color: BeigePalette.softBrown))),
    );
  }
}
