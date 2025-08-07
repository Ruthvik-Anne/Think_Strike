// ThinkStrike - Home Screen
// Created: 2025-08-07
// Author: Ruthvik-Anne

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

/// Main screen of the application
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Attempt to sync with backend when screen loads
    Provider.of<QuizProvider>(context, listen: false).sync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ThinkStrike'),
        actions: [
          // Manual sync button
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              Provider.of<QuizProvider>(context, listen: false).sync();
            },
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: quizProvider.getLocalQuizzes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No quizzes available'));
              }

              final quizzes = snapshot.data!;
              return ListView.builder(
                itemCount: quizzes.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(quizzes[i]['title']),
                  trailing: Icon(
                    quizzes[i]['sync_status'] == 1
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                    color: quizzes[i]['sync_status'] == 1
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement quiz creation
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}