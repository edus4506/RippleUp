import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/profile_viewModel.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/views/widgets/notification_dropdown.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUser();
    });
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<AuthViewModel>().logout();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<ProfileViewModel>().softDeleteAcc();
    await context.read<AuthViewModel>().deleteAcc();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final user = vm.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [NotificationDropdown()],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            user?.profilePictureUrl.isNotEmpty == true
                            ? NetworkImage(user!.profilePictureUrl)
                            : null,
                        child: user?.profilePictureUrl.isEmpty ?? true
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),

                      const SizedBox(width: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                _SettingsOption(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.editProfile),
                ),

                _SettingsOption(
                  icon: Icons.lock_outline,
                  label: 'Password',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.changePassword),
                ),

                const Divider(height: 1),

                _SettingsOption(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () {},
                ),

                _SettingsOption(
                  icon: Icons.info_outline,
                  label: 'About the App',
                  onTap: () {},
                ),

                const Divider(height: 1),

                _SettingsOption(
                  icon: Icons.logout,
                  label: 'Logout',
                  onTap: _confirmLogout,
                ),

                const Divider(height: 1),

                _SettingsOption(
                  icon: Icons.delete_forever,
                  label: 'Delete Account',
                  color: Colors.red,
                  onTap: _confirmDeleteAccount,
                ),
              ],
            ),
    );
  }
}

class _SettingsOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
