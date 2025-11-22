import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../providers/task_provider.dart';
import '../models/task_model.dart';

class TaskRepository {
  final TaskProvider provider = TaskProvider();

  // === AUTO REFRESH TOKEN HANDLER ===
  Future<http.Response> _withTokenRetry(
      Future<http.Response> Function(String token) requestFn) async {
    final prefs = await SharedPreferences.getInstance();
    String access = prefs.getString("accessToken") ?? "";
    String refresh = prefs.getString("refreshToken") ?? "";

    print("🔑 Using access token: $access");

    // First attempt
    http.Response response = await requestFn(access);

    // If not unauthorized → return
    if (response.statusCode != 401) return response;

    print("⚠ Access token expired → refreshing...");

    // TRY REFRESH TOKEN
    final refreshRes = await http.post(
      Uri.parse("${TaskProvider.baseUrl}/auth/refresh"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refresh}),
    );

    print("REFRESH STATUS: ${refreshRes.statusCode}");
    print("REFRESH BODY: ${refreshRes.body}");

    if (refreshRes.statusCode != 200) {
      print("❌ Refresh failed");
      return response; // original 401
    }

    final newAccess =
    jsonDecode(refreshRes.body)["data"]["accessToken"];

    await prefs.setString("accessToken", newAccess);

    print("✅ NEW ACCESS TOKEN SAVED: $newAccess");

    // RETRY ORIGINAL REQUEST
    return await requestFn(newAccess);
  }

  // === GET TASKS ===
  Future<Map<String, dynamic>> fetchTasks({
    required int page,
    required int limit,
    String? search,
    String? status,
  }) async {
    final res = await _withTokenRetry(
          (token) => provider.fetchTasks(
        token: token,
        page: page,
        limit: limit,
        search: search,
        status: status,
      ),
    );

    print("TASK LIST: ${res.body}");

    final body = jsonDecode(res.body);

    final tasks = (body["data"]["tasks"] as List)
        .map((e) => TaskModel.fromJson(e))
        .toList();

    return {
      "tasks": tasks,
      "total": body["data"]["total"],
      "page": body["data"]["page"],
      "limit": body["data"]["limit"],
    };
  }

  Future<bool> createTask(String title, String description) async {
    final res = await _withTokenRetry(
          (token) => provider.createTask(token, title, description),
    );
    return res.statusCode == 201;
  }

  Future<bool> updateTask(int id, String title, String desc) async {
    final res = await _withTokenRetry(
          (token) => provider.updateTask(token, id, title, desc),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteTask(int id) async {
    final res = await _withTokenRetry(
          (token) => provider.deleteTask(token, id),
    );
    return res.statusCode == 200;
  }

  Future<bool> toggleTask(int id) async {
    final res =
    await _withTokenRetry((token) => provider.toggleStatus(token, id));
    return res.statusCode == 200;
  }
}
