import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminManageUsersPage extends StatefulWidget {
  const AdminManageUsersPage({super.key});
  @override
  State<AdminManageUsersPage> createState() => _AdminManageUsersPageState();
}

class _AdminManageUsersPageState extends State<AdminManageUsersPage> {
  final _api = ApiService();
  List<dynamic> _users = [];
  String? _roleFilter;
  bool _loading = false;

  Future<void> _load() async {
    setState(()=> _loading = true);
    final q = _roleFilter != null ? "?role=${_roleFilter}" : "";
    final res = await _api.get('/admin/users'+q);
    setState(()=> _loading = false);
    if (res.statusCode == 200) {
      setState(()=> _users = jsonDecode(res.body) as List<dynamic>);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${res.statusCode}')));
    }
  }

  Future<void> _edit({Map<String,dynamic>? user}) async {
    final emailCtl = TextEditingController(text: user?['email']);
    String role = user?['role'] ?? 'student';
    final formKey = GlobalKey<FormState>();
    final passCtl = TextEditingController();
    await showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text(user==null?'Add User':'Edit User'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: emailCtl, decoration: const InputDecoration(labelText: 'Email'), validator: (v)=> (v==null||v.isEmpty)?'Required':null),
            const SizedBox(height: 8),
            if (user==null) TextFormField(controller: passCtl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true, validator: (v)=> (v==null||v.length<6)?'Min 6 chars':null)
            else TextFormField(controller: passCtl, decoration: const InputDecoration(labelText: 'New Password (optional)'), obscureText: true),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(value: role, decoration: const InputDecoration(labelText: 'Role'), items: const [
              DropdownMenuItem(value:'admin', child: Text('Admin')),
              DropdownMenuItem(value:'teacher', child: Text('Teacher')),
              DropdownMenuItem(value:'student', child: Text('Student')),
            ], onChanged: (v)=> role = v ?? 'student'),
          ]),
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            if (user == null) {
              final res = await _api.post('/admin/users', {'email': emailCtl.text.trim(),'password': passCtl.text,'role': role});
              if (res.statusCode == 200 || res.statusCode == 201) { Navigator.pop(context); await _load(); }
              else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create failed: ${res.statusCode}'))); }
            } else {
              final body = {'email': emailCtl.text.trim(),'role': role};
              if (passCtl.text.isNotEmpty) body['password'] = passCtl.text;
              final res = await _api.put('/admin/users/${user['id']}', body);
              if (res.statusCode == 200) { Navigator.pop(context); await _load(); }
              else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: ${res.statusCode}'))); }
            }
          }, child: const Text('Save'))
        ],
      );
    });
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(context: context, builder: (_)=> AlertDialog(
      title: const Text('Confirm delete'),
      content: const Text('This action cannot be undone.'),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: ()=> Navigator.pop(context, true), child: const Text('Delete'))
      ],
    )) ?? false;
    if (!ok) return;
    final res = await _api.delete('/admin/users/$id');
    if (res.statusCode == 200) { await _load(); }
    else { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: ${res.statusCode}'))); }
  }

  @override
  void initState(){ super.initState(); _load(); }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users'), actions: [
        IconButton(onPressed: ()=> _edit(), icon: const Icon(Icons.person_add)),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            const Text('Filter role:'), const SizedBox(width: 8),
            DropdownButton<String>(value: _roleFilter, hint: const Text('Any'), items: const [
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
              DropdownMenuItem(value: 'student', child: Text('Student')),
            ], onChanged: (v)=> setState(()=> _roleFilter = v)),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _load, child: const Text('Reload')),
          ]),
          const SizedBox(height: 8),
          Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
            itemCount: _users.length,
            itemBuilder: (_, i){
              final u = _users[i] as Map<String,dynamic>;
              return Card(child: ListTile(
                title: Text(u['email'] ?? ''),
                subtitle: Text('Role: ${u['role']} | id: ${u['id']}'),
                trailing: Wrap(spacing: 8, children: [
                  IconButton(onPressed: ()=> _edit(user: u), icon: const Icon(Icons.edit)),
                  IconButton(onPressed: ()=> _delete(u['id']), icon: const Icon(Icons.delete), color: Colors.red),
                ]),
              ));
            },
          ))
        ]),
      ),
    );
  }
}
