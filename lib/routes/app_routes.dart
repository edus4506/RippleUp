import 'package:flutter/material.dart';
import 'package:t5/views/pages/login_page.dart';
import 'package:t5/views/pages/register_page.dart';
import 'package:t5/views/pages/home_page.dart';
import 'package:t5/views/pages/chat_page.dart';
import 'package:t5/views/pages/feedback_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String chat = '/chat';
  static const String feedback = '/feedback';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
  };

  //arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case chat:
        final args = settings.arguments as Map;

        return MaterialPageRoute(
          builder: (_) =>
              ChatPage(eventId: args['eventId'], title: args['title']),
        );

      case feedback:
        final args = settings.arguments as Map;

        return MaterialPageRoute(
          builder: (_) => FeedbackPage(
            eventId: args['eventId'],
            title: args['title'],
          ),
        );
      
      default:
        return null;
    }
  }
}
