// ThinkStrike - Quiz Provider
// Created: 2025-08-07
// Author: Ruthvik-Anne

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Provider class for managing quiz data and offline synchronization
class QuizProvider extends ChangeNotifier {
  late Database _db;
  final String _api = 'http://127.0.0.1:8000';

  /// Initialize the provider and database
  QuizProvider() {
    _initDb();
  }

  /// Initialize the local SQLite database
  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'thinkstrike.db'),
      onCreate: (db, version) async {
        // Create tables
        await db.execute('''
          CREATE TABLE quizzes(
            id INTEGER PRIMARY KEY,
            title TEXT,
            sync_status INTEGER DEFAULT 0
          );
        ''');
      },
      version: 1,
    );
  }

  /// Synchronize with the backend server
  Future<void> sync() async {
    try {
      final res = await http.get(Uri.parse('$_api/quiz/1'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        
        // Update local database
        await _db.insert(
          'quizzes',
          {
            'id': data['id'],
            'title': data['title'],
            'sync_status': 1
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
      // Handle offline mode
    }
  }

  /// Get all quizzes from local database
  Future<List<Map<String, dynamic>>> getLocalQuizzes() async {
    return await _db.query('quizzes');
  }
}