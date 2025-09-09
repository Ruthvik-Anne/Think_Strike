import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/role.dart';

class AuthState extends ChangeNotifier {
  String? _token;
  UserRole _role = UserRole.unknown;
  bool _loading = false;

  String? get token => _token;
  UserRole get role => _role;
  bool get isLoading => _loading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty && _role != UserRole.unknown;

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    _token = sp.getString('token');
    _role = roleFromString(sp.getString('role'));
    notifyListeners();
    if (_token != null && _token!.isNotEmpty) {
      await refreshMe();
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true; notifyListeners();
    try {
      final uri = Uri.parse('${apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/'}auth/login');
      final res = await http.post(uri, headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _token = data['access_token'] as String?;
        _role = roleFromString(data['role'] as String?);
        final sp = await SharedPreferences.getInstance();
        if (_token != null) await sp.setString('token', _token!);
        await sp.setString('role', roleToString(_role));
        _loading = false; notifyListeners();
        return true;
      }
      _loading = false; notifyListeners();
      return false;
    } catch (_) {
      _loading = false; notifyListeners();
      return false;
    }
  }

  Future<bool> refreshMe() async {
    if (_token == null || _token!.isEmpty) return false;
    try {
      final uri = Uri.parse('${apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/'}auth/me');
      final res = await http.get(uri, headers: {'Authorization': 'Bearer $_token'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _role = roleFromString(data['role'] as String?);
        final sp = await SharedPreferences.getInstance();
        await sp.setString('role', roleToString(_role));
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('token'); await sp.remove('role');
    _token = null; _role = UserRole.unknown; notifyListeners();
  }
}
