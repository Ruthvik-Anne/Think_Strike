import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'glassmorphic_quiz_ui.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

const String backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:8000');

class AdminUserManagement extends StatefulWidget {
  @override
  _AdminUserManagementState createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  List users = [];
  bool loading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    await fetchUsers();
  }

  Map<String,String> authHeaders() {
    return {'Content-Type':'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<void> fetchUsers() async {
    setState(() => loading = true);
    try {
      final resp = await http.get(Uri.parse('$backendUrl/users'), headers: authHeaders());
      if (resp.statusCode == 200) {
        users = json.decode(resp.body);
      }
    } catch (e) { if (kDebugMode) print('fetch users err: $e'); }
    setState(() => loading = false);
  }

  Future<void> addUserDialog() async {
    final u = TextEditingController();
    final p = TextEditingController();
    String role = 'student';
    final res = await showDialog<bool>(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text('Add user'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: u, decoration: InputDecoration(labelText: 'Username')),
          TextField(controller: p, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
          DropdownButton<String>(value: role, onChanged: (v) { role = v!; }, items: ['student','teacher','admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList())
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          ElevatedButton(onPressed: () async {
            try {
              final resp = await http.post(Uri.parse('$backendUrl/auth/register'), headers: authHeaders(), body: json.encode({'username': u.text.trim(), 'password': p.text, 'role': role}));
              if (resp.statusCode == 201) {
                Navigator.pop(ctx, true);
              } else {
                Navigator.pop(ctx, false);
              }
            } catch (e) { Navigator.pop(ctx, false); }
          }, child: Text('Create'))
        ],
      );
    });
    if (res == true) fetchUsers();
  }

  Future<void> deleteUser(String id) async {
    try {
      final resp = await http.delete(Uri.parse('$backendUrl/users/$id'), headers: authHeaders());
      if (resp.statusCode == 200) fetchUsers();
    } catch (e) { if (kDebugMode) print('delete err: $e'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(70), child: GlassHeader(title: 'Admin - Users', categories: [])),
      body: loading ? Center(child: CircularProgressIndicator()) : Padding(
        padding: EdgeInsets.all(12),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: addUserDialog, child: Text('Add user'))
          ]),
          SizedBox(height:12),
          Expanded(child: ListView.separated(itemBuilder: (ctx, idx) {
            final u = users[idx];
            return ListTile(title: Text(u['username']), subtitle: Text(u['role']), trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => deleteUser(u['_id'])));
          }, separatorBuilder: (_,__) => Divider(), itemCount: users.length))
        ]),
      ),
    );
  }
}
