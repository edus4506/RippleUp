import 'package:flutter/material.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/data/repositories/favorite_repository.dart';
import 'package:t5/data/repositories/storage_repository.dart';
import 'package:t5/data/repositories/user_repository.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/viewModels/favorite_view_model.dart';
import 'routes/app_routes.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/profile_viewModel.dart';
import 'package:t5/viewModels/user_view_model.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';

import 'package:supabase_flutter/supabase_flutter.dart'; //for file storage

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zryedbkqhfitgsmpmajc.supabase.co',
    //annon public
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpyeWVkYmtxaGZpdGdzbXBtYWpjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1OTkwNTYsImV4cCI6MjA5MTE3NTA1Nn0.TnL2cVCFWeSIids6M38f-ed3YQKcHoPzyCW9DojACk8',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthViewModel(UserRepository(), StorageRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => ProfileViewModel(UserRepository(), StorageRepository())
      ),
      ChangeNotifierProvider(
          create: (_) => EventViewModel(EventRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => UserViewModel(UserRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => FavoriteViewModel(FavoriteRepository()),
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

      builder: (context, child) {
        return child!;
      },

      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}