class ApiConstants {
  static String get baseUrl =>
      "https://holbertonschool-portfolio-project-22a6.onrender.com/api/";

  // Authentication
  static const String login = "auth/login";
  static const String register = "auth/register";
  static const String childLogin = "auth/child-login";
  static const String refresh = "auth/refresh";
  static const String logout = "auth/logout";
  static const String logoutRefresh = "auth/logout-refresh";

  // Children
  static const String children = "children/";
}