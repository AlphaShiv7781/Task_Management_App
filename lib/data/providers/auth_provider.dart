import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_endpoints.dart';

class AuthProvider {
  Future<http.Response> login(String email, String password) {
    return http.post(
      Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );
  }

  Future<http.Response> register(String name, String email, String password) {
    return http.post(
      Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.register),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );
  }
}
