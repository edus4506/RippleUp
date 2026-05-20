import 'package:flutter/material.dart';
import 'package:t5/views/pages/authentication/login_page.dart';
import 'package:t5/views/pages/authentication/register_page.dart';
import 'package:t5/views/pages/home_page.dart';
import 'package:t5/views/pages/messages/chat_page.dart';
import 'package:t5/views/pages/events/feedback_page.dart';
import 'package:t5/views/pages/events/reviews_history_page.dart';
import 'package:t5/views/pages/settings/change_password_page.dart';
import 'package:t5/views/pages/settings/edit_profile_page.dart';
import 'package:t5/views/pages/settings/settings_page.dart';
import 'package:t5/views/pages/splash_page.dart';
import 'package:t5/views/pages/social/public_profile_page.dart';
import 'package:t5/views/pages/social/followers_following_page.dart';
import 'package:t5/views/pages/messages/direct_messages_page.dart';
import 'package:t5/views/pages/events/participants_page.dart'; // 🚀 Importado o teu ecrã de participantes

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String chat = '/chat';
  static const String feedback = '/feedback';
  static const String settings = '/settings';
  static const String editProfile = '/settings/edit-profile';
  static const String changePassword = '/settings/change-password';
  static const String reviewsHistory = '/reviews-history';
  static const String directMessages = '/direct-messages';
  static const String publicProfile = '/public-profile';
  static const String followersFollowing = '/followers-following';
  static const String participants =
      '/participants'; // 🚀 Nova constante de rota

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashPage(),
    home: (context) => const HomePage(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    settings: (context) => const SettingsPage(),
    editProfile: (context) => const EditProfilePage(),
    changePassword: (context) => const ChangePasswordPage(),
    reviewsHistory: (context) => const ReviewsHistoryPage(),
    directMessages: (context) => const DirectMessagesPage(),
  };

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
            endDate: args['endDate'],
            currentUserId: args['currentUserId'],
          ),
        );

      case publicProfile:
        final args = settings.arguments as Map;
        return MaterialPageRoute(
          builder: (_) => PublicProfilePage(userId: args['userId'] as String),
        );

      case followersFollowing:
        final args = settings.arguments as Map;
        return MaterialPageRoute(
          builder: (_) => FollowersFollowingPage(
            userId: args['userId'] as String,
            initialTab: (args['initialTab'] as int?) ?? 0,
          ),
        );

      // 🚀 Nova rota dinâmica adicionada de forma limpa para os participantes
      case participants:
        final args = settings.arguments as Map;
        return MaterialPageRoute(
          builder: (_) => ParticipantsPage(
            eventId: args['eventId'] as String,
            creatorId: args['creatorId'] as String,
          ),
        );

      default:
        return null;
    }
  }
}
