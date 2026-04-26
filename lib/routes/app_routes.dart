import 'package:flutter/material.dart';
import 'package:t5/views/pages/login_page.dart';
import 'package:t5/views/pages/register_page.dart';
import 'package:t5/views/pages/home_page.dart';
import 'package:t5/views/pages/chat_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String chat = '/chat';

  // 
  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
  };

  //arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case chat:
        final eventId = settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => ChatPage(eventId: eventId),
        );

      default:
        return null;
    }
  }
}