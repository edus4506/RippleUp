import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/repositories/events/event_repository.dart';
import 'package:t5/data/repositories/events/favorite_event_repository.dart';
import 'package:t5/data/repositories/social/follow_repository.dart';
import 'package:t5/data/repositories/messages/message_repository.dart';
import 'package:t5/data/repositories/social/participation_repository.dart';
import 'package:t5/services/storage/storage_service.dart';
import 'package:t5/data/repositories/social/user_repository.dart';
import 'package:t5/data/repositories/reviews/review_repository.dart';
import 'package:t5/data/repositories/social/notification_repository.dart';
import 'package:t5/data/repositories/messages/direct_message_repository.dart';
import 'package:t5/data/repositories/messages/event_chat_repository.dart';

import 'package:t5/services/social/profile_image_service.dart';

import 'package:t5/viewModels/events/event_viewModel.dart';
import 'package:t5/viewModels/events/favorite_event_viewModel.dart';
import 'package:t5/viewModels/authenthication/auth_viewModel.dart';
import 'package:t5/viewModels/messages/message_viewModel.dart';
import 'package:t5/viewModels/social/profile_viewModel.dart';
import 'package:t5/viewModels/reviews/review_viewModel.dart';
import 'package:t5/viewModels/social/notification_viewModel.dart';
import 'package:t5/viewModels/search/search_viewModel.dart';
import 'package:t5/viewModels/search/search_users_viewModel.dart';
import 'package:t5/viewModels/social/user_view_model.dart';
import 'package:t5/viewModels/messages/direct_message_viewModel.dart';
import 'package:t5/viewModels/events/participants_view_model.dart'; // ✅ ADICIONADO

import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zryedbkqhfitgsmpmajc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpyeWVkYmtxaGZpdGdzbXBtYWpjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1OTkwNTYsImV4cCI6MjA5MTE3NTA1Nn0.TnL2cVCFWeSIids6M38f-ed3YQKcHoPzyCW9DojACk8',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => UserRepository()),
        Provider(create: (_) => NotificationRepository()),
        Provider(create: (_) => StorageRepository()),
        Provider(create: (_) => EventRepository()),
        Provider(create: (_) => FavoriteRepository()),
        Provider(create: (_) => ParticipationRepository()),
        Provider(create: (_) => MessageRepository()),
        Provider(create: (_) => ReviewRepository()),
        Provider(create: (_) => FollowRepository()),
        Provider(create: (_) => DirectMessageRepository()),
        Provider(create: (_) => EventChatRepository()),
        ProxyProvider<StorageRepository, ProfileImageService>(
          update: (_, storageRepo, _) => ProfileImageService(storageRepo),
        ),

        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            context.read<UserRepository>(),
            context.read<ProfileImageService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(
            context.read<UserRepository>(),
            context.read<ProfileImageService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => AppNotificationViewModel(
            context.read<NotificationRepository>(),
            context.read<ParticipationRepository>(),
            context.read<EventRepository>(),
            context.read<UserRepository>(),
            context.read<FollowRepository>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => EventViewModel(
            context.read<EventRepository>(),
            context.read<StorageRepository>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => UserViewModel(context.read<UserRepository>()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              FavoriteViewModel(context.read<FavoriteRepository>()),
        ),

        ChangeNotifierProvider(
          create: (context) => MessageViewModel(
            context.read<MessageRepository>(),
            context.read<ParticipationRepository>(),
            context.read<EventRepository>(),
            EventChatRepository(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              ReviewViewModel(context.read<ReviewRepository>()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              SearchUsersViewModel(context.read<UserRepository>()),
        ),

        ChangeNotifierProvider(
          create: (context) => SearchViewModel(context.read<EventViewModel>()),
        ),

        ChangeNotifierProvider(
          create: (context) => DirectMessageViewModel(
            context.read<DirectMessageRepository>(),
            context.read<UserRepository>(),
          ),
        ),

        // ✅ ADICIONADO: ParticipantsViewModel
        ChangeNotifierProvider(
          create: (context) => ParticipantsViewModel(
            context.read<ParticipationRepository>(),
            context.read<UserRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ripple Up',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
