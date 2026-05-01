import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/user.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/profile_viewModel.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameController = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProfileViewModel>().loadUser();
      final user = context.read<ProfileViewModel>().user;
      if (user != null) {
        _nameController.text = user.name;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final vm = context.read<ProfileViewModel>();

    await vm.updateUserProfile(
      updatedUser: Users(
        name: _nameController.text.trim(),
        email: vm.user?.email ?? '',
        profilePictureUrl: vm.user?.profilePictureUrl ?? '',
      ),
    );

    if (!mounted) return;

    setState(() => _editing = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    await context.read<ProfileViewModel>().updateUserProfile(
      profilePicture: picked,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Photo updated')));
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

    if (confirmed != true) return;

    await context.read<ProfileViewModel>().softDeleteAcc();
    await context.read<AuthViewModel>().deleteAcc();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
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

    if (confirmed != true) return;

    await context.read<AuthViewModel>().logout();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final profileVm = context.watch<ProfileViewModel>();
    final user = profileVm.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (_editing)
            TextButton(
              onPressed: profileVm.isLoading ? null : _saveProfile,
              child: const Text('Save'),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit profile',
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: profileVm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Profile photo ---
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage:
                  user?.profilePictureUrl.isNotEmpty == true
                      ? NetworkImage(user!.profilePictureUrl)
                      : null,
                  child: user?.profilePictureUrl.isEmpty ?? true
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Personal info ---
          Text('Personal Info', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),

          TextField(
            controller: _nameController,
            enabled: _editing,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: user?.email ?? '',
              prefixIcon: const Icon(Icons.email_outlined),
              border: const OutlineInputBorder(),
            ),
            controller: TextEditingController(text: user?.email ?? ''),
          ),

          const SizedBox(height: 32),

          // --- Account ---
          Text('Account', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.red),
            ),
            onTap: _confirmDeleteAccount,
          ),

          const SizedBox(height: 32),

          // --- Session ---
          Text('Session', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }
}