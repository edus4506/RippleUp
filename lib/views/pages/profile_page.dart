import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos um SingleChildScrollView para que a página faça scroll se o ecrã for pequeno
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          // 1. Avatar do Utilizador
          const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 16),

          // 2. Informações de Texto
          const Text(
            'Nome do Utilizador',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'utilizador@email.com',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // 3. Lista de Opções (Estilo menu)
          _buildProfileOption(Icons.settings, 'Configurações'),
          _buildProfileOption(Icons.notifications, 'Notificações'),
          _buildProfileOption(Icons.help_outline, 'Ajuda e Suporte'),
          
          const SizedBox(height: 40),

          // 4. Botão de Logout (Sair)
          // Repara que este botão vai usar o estilo do teu AppTheme automaticamente!
          ElevatedButton(
            onPressed: () {
              // Ao fazer logout, limpamos a pilha e voltamos para o Login
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400, // Sobrescrevemos apenas a cor para vermelho
            ),
            child: const Text('SAIR DA CONTA'),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para criar as linhas do menu
  Widget _buildProfileOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Ação da opção
      },
    );
  }
}