import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart' as api;

class AdminScreen extends StatefulWidget {
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic>? _users;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await api.getUsers();
      setState(() => _users = res);
    } catch (e) {
      setState(() => _error = 'Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: ListTile(
                title: const Text('Users (backend)', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.people, color: Colors.white),
                onTap: _load,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white)))
                  : _users == null
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemBuilder: (context, index) {
                            final u = _users![index];
                            return GlassCard(
                              child: ListTile(
                                title: Text('User: ${u['id']}', style: const TextStyle(color: Colors.white)),
                                subtitle: Text('Role: ${u['role']}', style: const TextStyle(color: Colors.white70)),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemCount: _users!.length,
                        ),
            )
          ],
        ),
      ),
    );
  }
}


