// ThinkStrike - Main Application
// Created: 2025-08-07
// Author: Ruthvik-Anne

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/home_screen.dart';

/// Main entry point of the application
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run the app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const ThinkStrikeApp(),
    ),
  );
}

/// Root widget of the application
class ThinkStrikeApp extends StatelessWidget {
  const ThinkStrikeApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThinkStrike',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Enable Material 3 design
      ),
      home: const HomeScreen(),
    );
  }
}