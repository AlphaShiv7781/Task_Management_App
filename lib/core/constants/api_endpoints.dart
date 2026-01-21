class ApiEndpoints {
  static const baseUrl = "https://task-management-hwld.onrender.com/";

  static const login = "/auth/login";
  static const register = "/auth/register";

  // Tasks
  static const tasks = "/tasks";
  static const toggleStatus = "/tasks/:id/toggle";
}
