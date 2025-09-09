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

  Uri _uri(String path) {
    final base = apiBaseUrl.endsWith('/') ? apiBaseUrl.substring(0, apiBaseUrl.length - 1) : apiBaseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Future<http.Response> get(String path) async {
    final headers = await _headers();
    return http.get(_uri(path), headers: headers);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    return http.post(_uri(path), headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    return http.put(_uri(path), headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String path) async {
    final headers = await _headers();
    return http.delete(_uri(path), headers: headers);
  }
}
