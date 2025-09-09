import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AdminHomePage extends StatefulWidget { const AdminHomePage({super.key}); @override State<AdminHomePage> createState()=> _AdminHomePageState(); }
class _AdminHomePageState extends State<AdminHomePage> {
  final _email = TextEditingController(); final _password = TextEditingController(); String _role = 'teacher';
  final _formKey = GlobalKey<FormState>(); final _api = ApiService(); bool _busy=false;
  Future<void> _createUser() async {
    if(!_formKey.currentState!.validate()) return; setState(()=> _busy=true);
    final res = await _api.post('/auth/register', {'email': _email.text.trim(),'password': _password.text.trim(),'role': _role});
    setState(()=> _busy=false);
    if(res.statusCode==201){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User created'))); _email.clear(); _password.clear(); }
    else { try{ final msg = jsonDecode(res.body)['detail'] ?? 'Failed'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg'))); } catch(_){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error creating user')));} }
  }
  @override Widget build(BuildContext context){
    final auth = context.watch<AuthState>();
    return Scaffold(appBar: AppBar(title: const Text('Admin Dashboard'), actions:[IconButton(onPressed: ()=> auth.logout(), icon: const Icon(Icons.logout))]),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth:560), child: Card(elevation:8, child: Padding(padding: const EdgeInsets.all(24), child:
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children:[
          const Text('Create User', style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)), SizedBox(height:8), ElevatedButton.icon(onPressed: ()=> Navigator.pushNamed(context, '/admin/users'), icon: Icon(Icons.group), label: Text('Manage Users')), SizedBox(height:12), const SizedBox(height:12),
          Form(key:_formKey, child: Column(children:[
            TextFormField(controller:_email, decoration: const InputDecoration(labelText:'Email'), validator:(v)=> (v==null||v.isEmpty)?'Enter email':null),
            const SizedBox(height:12),
            TextFormField(controller:_password, obscureText: true, decoration: const InputDecoration(labelText:'Password'), validator:(v)=> (v==null||v.isEmpty)?'Enter password':null),
            const SizedBox(height:12),
            DropdownButtonFormField<String>(value:_role, decoration: const InputDecoration(labelText:'Role'), items: const [
              DropdownMenuItem(value:'teacher', child: Text('Teacher')), DropdownMenuItem(value:'student', child: Text('Student')), DropdownMenuItem(value:'admin', child: Text('Admin'))
            ], onChanged:(v)=> setState(()=> _role = v ?? 'teacher')),
            const SizedBox(height:16),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _busy? null : _createUser, icon: _busy? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.person_add), label: const Text('Create User'))),
          ])),
        ]))))));
  }
}
