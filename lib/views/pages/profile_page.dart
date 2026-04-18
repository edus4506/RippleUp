import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../viewModels/profile_viewModel.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:provider/provider.dart';
import 'package:t5/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


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
          CircleAvatar(
            radius: 60,
            backgroundImage: vm.user?.profilePictureUrl != null
                ? NetworkImage(vm.user!.profilePictureUrl)
                : null,
            child: vm.user?.profilePictureUrl == null
                ? const Icon(Icons.person, size: 80)
                : null,
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

          ElevatedButton(
            onPressed: () async {
              final picker = ImagePicker();

              final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);

              if (pickedFile == null) return;

              //final file = File(pickedFile.path); //later uncomment and put below for android use

              await context.read<ProfileViewModel>().updateUserProfile(profilePicture: pickedFile);
            },
            child: const Text("Alterar foto"),
          ),

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

          ElevatedButton(
            onPressed: vm.isLoading
                ? null
                : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Eliminar conta"),
                        content: const Text(
                          "Tens a certeza? Esta ação não pode ser desfeita.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              "Eliminar",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    final profileVM = context.read<ProfileViewModel>();
                    final authVM = context.read<AuthViewModel>();

                    await profileVM.softDeleteAcc();
                    await authVM.deleteAcc();

                    if (!context.mounted) return;

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
            ),
            child: vm.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("ELIMINAR CONTA"),
          ),
        ],
      ),
    );
  }
}