import 'package:flutter/material.dart';
import '../../viewModels/profile_viewModel.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // botão não faz nada
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: (vm.user?.profilePictureUrl != null &&
                      vm.user!.profilePictureUrl.isNotEmpty)
                  ? NetworkImage(vm.user!.profilePictureUrl)
                  : null,
              child: (vm.user?.profilePictureUrl == null ||
                      vm.user!.profilePictureUrl.isEmpty)
                  ? const Icon(Icons.person, size: 80)
                  : null,
            ),

            const SizedBox(height: 16),

            if (vm.isLoading)
              const CircularProgressIndicator()
            else ...[
              Text(
                vm.user?.name ?? "Sem nome",
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                vm.user?.email ?? "Sem email",
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.event_rounded),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}