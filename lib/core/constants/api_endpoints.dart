class ApiEndpoints {
  static const baseUrl = "https://task-manager-backend-7j1a.onrender.com";

  static const login = "/auth/login";
  static const register = "/auth/register";

  // Tasks
  static const tasks = "/tasks";
  static const toggleStatus = "/tasks/:id/toggle";
}
