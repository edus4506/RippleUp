import 'package:flutter/material.dart';
import 'package:t5/data/repositories/user_repository.dart';
import 'routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'package:t5/viewmodels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/profile_viewModel.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => ProfileViewModel(UserRepository())
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
      title: 'Minha App',
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