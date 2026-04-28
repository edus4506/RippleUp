import 'package:flutter/material.dart';
import '../../viewModels/profile_viewModel.dart';
import 'package:provider/provider.dart';
import '../widgets/profile_tabs/favorite_events_widget.dart';
import '../widgets/profile_tabs/current_events_widget.dart';
import '../widgets/profile_tabs/history_events_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedIndex = 0; // 0=current, 1=history, 2=favorites

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUser();
    });
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return const CurrentEventsWidget();
      case 1:
        return const HistoryEventsWidget();
      case 2:
        return const FavoriteEventsWidget();
      default:
        return const SizedBox();
    }
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
            tooltip: "Settings",
            onPressed: () {},
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
              backgroundImage:
                  (vm.user?.profilePictureUrl != null &&
                      vm.user!.profilePictureUrl.isNotEmpty)
                  ? NetworkImage(vm.user!.profilePictureUrl)
                  : null,
              child:
                  (vm.user?.profilePictureUrl == null ||
                      vm.user!.profilePictureUrl.isEmpty)
                  ? const Icon(Icons.person, size: 80)
                  : null,
            ),

            const SizedBox(height: 16),

            if (vm.isLoading)
              const CircularProgressIndicator()
            else ...[
              Text(
                vm.user?.name ?? "No name",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                vm.user?.email ?? "No email",
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
                    icon: Icon(
                      Icons.event_rounded,
                      color: selectedIndex == 0 ? Colors.green : Colors.grey,
                    ),
                    tooltip: "Current Events",
                    onPressed: () {
                      setState(() => selectedIndex = 0);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.history,
                      color: selectedIndex == 1 ? Colors.green : Colors.grey,
                    ),
                    tooltip: "Event History",
                    onPressed: () {
                      setState(() => selectedIndex = 1);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: selectedIndex == 2 ? Colors.green : Colors.grey,
                    ),
                    tooltip: "Favorite Events",
                    onPressed: () {
                      setState(() => selectedIndex = 2);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // dynamic content (favorites, history, etc)
            _buildContent(),
          ],
        ),
      ),
    );
  }
}
