import 'package:flutter/material.dart';
import '../theme.dart';

class StudentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Portal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: ListTile(
                title: const Text('Take Quiz', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Attempt available quizzes', style: TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: ListTile(
                title: const Text('Progress', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Track your performance', style: TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


