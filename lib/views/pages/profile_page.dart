import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    /// Scrollable layout for smaller screens
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          /// User avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.primary,
            child: Icon(
              Icons.person,
              size: 80,
              color: theme.colorScheme.onPrimary,
            ),
          ),

          const SizedBox(height: 16),

          /// User name
          Text(
            'Nome do Utilizador',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 24),
          ),

          /// User email
          Text(
            'utilizador@email.com',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),

          const SizedBox(height: 32),

          /// Profile options menu
          _buildProfileOption(context, Icons.settings, 'Configurações'),
          _buildProfileOption(context, Icons.notifications, 'Notificações'),
          _buildProfileOption(context, Icons.help_outline, 'Ajuda e Suporte'),

          const SizedBox(height: 40),

          /// Logout button
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400, // override only this
            ),
            child: const Text('SAIR DA CONTA'),
          ),
        ],
      ),
    );
  }

  /// Helper widget for profile menu options
  Widget _buildProfileOption(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: theme.iconTheme.color,
      ),

      /// Option title
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),

      /// Arrow icon
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),

      onTap: () {
        // Option action
      },
    );
  }
}