import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 32),

            // EMAIL
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),

            // PASSWORD
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),

            // ERRO
            if (vm.errorMessage != null) ...[
              Text(
                vm.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
            ],

            // BOTÃO LOGIN
            ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      await vm.login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );

                      if (vm.currentUser != null) {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.home,
                        );
                      }
                    },
              child: vm.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('ENTRAR'),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () {
                // futuro registo
              },
              child: const Text('Não tem conta? Registe-se'),
            ),
          ],
        ),
      ),
    );
  }
}