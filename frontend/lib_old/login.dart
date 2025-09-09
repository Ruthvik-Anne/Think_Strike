import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'glassmorphic_quiz_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:8000');

class LoginPage extends StatefulWidget {
  final Function onLogged;
  const LoginPage({Key? key, required this.onLogged}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> doLogin() async {
    setState((){ loading = true; error = null; });
    try {
      final resp = await http.post(Uri.parse('$backendUrl/auth/login'), headers: {'Content-Type':'application/json'}, body: json.encode({'username': userCtrl.text.trim(), 'password': passCtrl.text}));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        await prefs.setString('role', data['role']);
        widget.onLogged();
      } else {
        setState(() => error = 'Invalid credentials');
      }
    } catch (e) {
      if (kDebugMode) print('login error: $e');
      setState(() => error = 'Login failed');
    } finally { setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeigePalette.baseBackground,
      body: Center(child: GlassContainer(padding: EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Sign in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height:12),
        TextField(controller: userCtrl, decoration: InputDecoration(labelText: 'Username')),
        TextField(controller: passCtrl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
        SizedBox(height:12),
        if (error != null) Text(error!, style: TextStyle(color: Colors.red)),
        SizedBox(height:12),
        ElevatedButton(onPressed: loading ? null : doLogin, child: loading ? CircularProgressIndicator() : Text('Login'))
      ]))),
    );
  }
}
