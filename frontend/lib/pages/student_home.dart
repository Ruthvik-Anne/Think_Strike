import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class StudentHomePage extends StatelessWidget { const StudentHomePage({super.key}); @override Widget build(BuildContext context){
  final auth = context.watch<AuthState>();
  return Scaffold(appBar: AppBar(title: const Text('Student Portal'), actions:[IconButton(onPressed: ()=> auth.logout(), icon: const Icon(Icons.logout))]), body: const Center(child: Text('Student area')));
}}
