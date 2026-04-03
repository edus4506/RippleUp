import 'package:flutter/material.dart';
import 'package:t5/views/pages/login_page.dart';
import '../views/pages/home_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    login: (context) => const LoginPage(),
  };
}