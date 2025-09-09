import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiService {
  Future<Map<String, String>> _headers() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('token');
    final h = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    return http.post(Uri.parse('$apiBaseUrl$path'), headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> get(String path) async {
    final headers = await _headers();
    return http.get(Uri.parse('$apiBaseUrl$path'), headers: headers);
  }
}
