import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  ApiClient._();
  static final instance = ApiClient._();
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8787',
  );

  Future<Map<String, String>> _headers() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    return http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String path) async {
    return http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
  }
}