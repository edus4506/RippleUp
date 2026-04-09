import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../viewModels/profile_viewModel.dart';
import 'package:t5/viewmodels/authViewModel/auth_viewModel.dart';
import 'package:provider/provider.dart';
import 'package:t5/theme/app_theme.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      context.read<ProfileViewModel>().loadUser();
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 60,
            //backgroundColor: theme.colorScheme.primary, not recognising theme
            child: Icon(
              Icons.person,
              size: 80,
              //color: theme.colorScheme.onPrimary, //not recognizing theme
            ),
          ),

          const SizedBox(height: 16),

          if (vm.isLoading)
            const CircularProgressIndicator()
          else ...[
            Text(
              vm.user?.name ?? "Sem nome",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              vm.user?.email ?? "Sem email",
              style: const TextStyle(color: Colors.grey),
            ),
          ],

          const SizedBox(height: 40),

          ElevatedButton (
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
              if (!mounted) return;

              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('SAIR DA CONTA'),
          ),
        ],
      ),
    );
  }
}