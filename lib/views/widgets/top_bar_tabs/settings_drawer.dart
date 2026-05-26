import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/social/user.dart';
import 'package:t5/theme/palette.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/viewModels/authentication/auth_viewModel.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';
import 'package:t5/viewModels/social/profile_viewModel.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  late final TextEditingController _nameController;
  bool _isSaving = false;

  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<ProfileViewModel>().user;
      _nameController.text = user?.name ?? '';
      _emailController.text = user?.email ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    await context.read<ProfileViewModel>().updateUserProfile(
      profilePicture: picked,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Photo updated')));
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final vm = context.read<ProfileViewModel>();
    await vm.updateUserProfile(
      updatedUser: Users(
        uid: vm.user!.uid,
        name: _nameController.text.trim(),
        email: vm.user?.email ?? '',
        profilePictureUrl: vm.user?.profilePictureUrl ?? '',
      ),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    context.read<EventViewModel>().resetFilters();
    await context.read<AuthViewModel>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  Future<void> _confirmDeleteAccount() async {
    final email = context.read<ProfileViewModel>().user?.email ?? '';
    final eventVm = context.read<EventViewModel>();
    final profileVm = context.read<ProfileViewModel>();
    final authVm = context.read<AuthViewModel>();

    final passwordController = TextEditingController();
    bool obscure = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          String? errorText;
          return StatefulBuilder(
            builder: (ctx, setStateDialog) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text('Delete Account', style: TextStyle(fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This will permanently delete your account. Please enter your password to confirm.',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: errorText,
                      labelStyle: const TextStyle(color: Colors.black45),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.black38,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black38,
                          size: 20,
                        ),
                        onPressed: () =>
                            setStateDialog(() => obscure = !obscure),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (passwordController.text.trim().isEmpty) {
                      setStateDialog(
                        () => errorText = 'Please enter your password',
                      );
                      return;
                    }
                    Navigator.pop(ctx, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
      ),
    );

    final password = passwordController.text.trim();
    passwordController.dispose();

    if (confirmed != true || !mounted) return;

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
        credential,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect password. Account not deleted.'),
        ),
      );
      return;
    }

    eventVm.resetFilters();
    await profileVm.softDeleteAcc();
    await authVm.deleteAcc();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final user = vm.user;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.88,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          bottomLeft: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              child: Row(
                children: [
                  Text(
                    'Profile Settings',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      color: const Color(0xFF1B1B1B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.grey.shade100, height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Information ──
                    Text(
                      'Profile Information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Palette.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Avatar
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Palette.primary.withValues(alpha: 0.3),
                                width: 2.5,
                              ),
                            ),
                            child: ClipOval(
                              child:
                                  (user?.profilePictureUrl != null &&
                                      user!.profilePictureUrl.isNotEmpty)
                                  ? Image.network(
                                      user.profilePictureUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => _placeholder(),
                                    )
                                  : _placeholder(),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Palette.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Full Name
                    _FieldLabel(label: 'Full Name'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _nameController,
                      hint: 'Your name',
                      icon: Icons.person_outline_rounded,
                    ),

                    const SizedBox(height: 14),

                    // Email (disabled)
                    _FieldLabel(label: 'Email'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                      enabled: false,
                    ),

                    const SizedBox(height: 20),

                    // Save Changes
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Palette.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isSaving ? null : _saveProfile,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    Divider(color: Colors.grey.shade100),
                    const SizedBox(height: 20),

                    // ── Account ──
                    Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Palette.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _AccountOption(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change Password',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.changePassword);
                      },
                    ),
                    const SizedBox(height: 8),
                    _AccountOption(
                      icon: Icons.rate_review_outlined,
                      label: 'Reviews History',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.reviewsHistory);
                      },
                    ),
                    const SizedBox(height: 8),
                    _AccountOption(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & Support',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.helpSupport),
                    ),
                    const SizedBox(height: 8),
                    _AccountOption(
                      icon: Icons.info_outline_rounded,
                      label: 'About the App',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.about),
                    ),
                    const SizedBox(height: 8),
                    _AccountOption(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      onTap: _confirmLogout,
                    ),
                    const SizedBox(height: 8),
                    _AccountOption(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete Account',
                      color: Colors.red,
                      onTap: _confirmDeleteAccount,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Palette.greenLight,
    child: const Icon(Icons.person, size: 32, color: Palette.primary),
  );
}

// ─────────────────────────────────────────
// Field Label
// ─────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF333333),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Input Field
// ─────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool enabled;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1B1B1B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Palette.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Account Option
// ─────────────────────────────────────────

class _AccountOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _AccountOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF1B1B1B);
    return Material(
      color: color != null
          ? color!.withValues(alpha: 0.05)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: (color ?? Palette.primary).withValues(alpha: 0.12),
        highlightColor: (color ?? Palette.primary).withValues(alpha: 0.07),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color != null
                  ? color!.withValues(alpha: 0.15)
                  : Colors.grey.shade100,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: c, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: c,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: color != null
                    ? color!.withValues(alpha: 0.4)
                    : Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
