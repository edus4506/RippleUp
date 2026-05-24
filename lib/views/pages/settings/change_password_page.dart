import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:t5/theme/palette.dart';
import 'package:t5/viewModels/authenthication/auth_viewModel.dart';
import 'package:t5/views/widgets/top_bar_tabs/top_bar.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final current = _currentController.text.trim();
    final newPass = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    if (newPass != confirm) {
      _showSnack('Passwords do not match');
      return;
    }
    if (newPass.length < 6) {
      _showSnack('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    final vm = context.read<AuthViewModel>();
    await vm.changePassword(current, newPass);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (vm.errorMessage != null) {
      _showSnack(vm.errorMessage!);
    } else {
      _showSnack('Password updated successfully');
      Navigator.pop(context);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4EF),
      appBar: TopBar(
        title: 'Password',
        leftWidget: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 4),

            // ── Card ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + title
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Palette.greenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lock_outline_rounded,
                            color: Palette.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _FieldLabel(label: 'Current Password'),
                  const SizedBox(height: 6),
                  _PasswordField(
                    controller: _currentController,
                    hint: 'Enter current password',
                    show: _showCurrent,
                    onToggle: () =>
                        setState(() => _showCurrent = !_showCurrent),
                  ),

                  const SizedBox(height: 16),

                  _FieldLabel(label: 'New Password'),
                  const SizedBox(height: 6),
                  _PasswordField(
                    controller: _newController,
                    hint: 'Enter new password',
                    show: _showNew,
                    onToggle: () => setState(() => _showNew = !_showNew),
                  ),

                  const SizedBox(height: 16),

                  _FieldLabel(label: 'Confirm New Password'),
                  const SizedBox(height: 6),
                  _PasswordField(
                    controller: _confirmController,
                    hint: 'Repeat new password',
                    show: _showConfirm,
                    onToggle: () =>
                        setState(() => _showConfirm = !_showConfirm),
                  ),

                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Material(
                      color: Palette.primary,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: _isLoading ? null : _handleChangePassword,
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Update Password',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Hint card
            Container(
              decoration: BoxDecoration(
                color: Palette.greenLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Palette.primary.withOpacity(0.15)),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Palette.primary.withOpacity(0.7), size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Password must be at least 6 characters long.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Palette.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
// Password Field
// ─────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool show;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.show,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !show,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1B1B1B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Icon(
              show
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Palette.primary, width: 1.5),
        ),
      ),
    );
  }
}
