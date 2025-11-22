import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider authProvider;

  AuthRepository(this.authProvider);

  Future<bool> login(String email, String password) async {
    final response = await authProvider.login(email, password);

    // Expecting: { success, message, data: { accessToken, refreshToken } }
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body["data"];

      final accessToken = data["accessToken"];
      final refreshToken = data["refreshToken"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("accessToken", accessToken);
      if (refreshToken != null) {
        await prefs.setString("refreshToken", refreshToken);
      }

      return true;
    }

    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    final response = await authProvider.register(name, email, password);

    // Accept 201 or 200 as success (backend-dependent)
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");
  }
}
