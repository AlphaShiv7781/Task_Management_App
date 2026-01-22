import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskProvider {
  static const baseUrl = "https://task-management-hwld.onrender.com";

  Future<http.Response> fetchTasks({
    required String token,
    required int page,
    required int limit,
    String? search,
    String? status,
  }) {
    final params = {
      "page": page.toString(),
      "limit": limit.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      params["search"] = search;
    }

    if (status != null && status != "all") {
      params["status"] = status;
    }

    final url = Uri.parse("$baseUrl/tasks").replace(queryParameters: params);

    print("➡️ GET: $url");

    return http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );
  }

  Future<http.Response> createTask(
      String token, String title, String desc) {
    return http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"title": title, "description": desc}),
    );
  }

  Future<http.Response> updateTask(
      String token, int id, String title, String desc) {
    return http.patch(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "title": title,
        "description": desc,
      }),
    );
  }

  Future<http.Response> deleteTask(String token, int id) {
    return http.delete(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  Future<http.Response> toggleStatus(String token, int id) {
    return http.patch(
      Uri.parse("$baseUrl/tasks/$id/toggle"),
      headers: {"Authorization": "Bearer $token"},
    );
  }
}
