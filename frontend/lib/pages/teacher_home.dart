import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class TeacherHomePage extends StatelessWidget { const TeacherHomePage({super.key}); @override Widget build(BuildContext context){
  final auth = context.watch<AuthState>();
  return Scaffold(appBar: AppBar(title: const Text('Teacher Dashboard'), actions:[IconButton(onPressed: ()=> auth.logout(), icon: const Icon(Icons.logout))]), body: const Center(child: Text('Teacher tools')));
}}
