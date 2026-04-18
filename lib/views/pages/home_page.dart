import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart'; // Garante que o caminho está correto
import 'profile_page.dart';
import 'events_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Conteúdo de cada aba
  final List<Widget> _pages = [
    const EventsPage(),
    const Center(child: Text('Tarefas', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Favoritos', style: TextStyle(fontSize: 24))),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      
      // O corpo muda conforme o índice selecionado
      body: _pages[_currentIndex],

      // AQUI ADICIONAS O TEU WIDGET CUSTOMIZADO
      // Ele vai ler automaticamente as cores do AppTheme que definiste
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}