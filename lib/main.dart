import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'data/repositories/user_repository.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthViewModel(UserRepository()),
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
      initialRoute: AppRoutes.login,

      routes: AppRoutes.routes,
    );
  }
}