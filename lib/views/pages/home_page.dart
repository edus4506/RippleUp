import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'profile_page.dart';
import 'events_page.dart';
import '../dialogs/event_filter_dialog.dart';
import '../dialogs/create_event_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const EventsPage(),
    const ProfilePage(),
  ];

  void _openFilterModal() {
    showDialog(
      context: context,
      builder: (_) => const EventFilterDialog(),
    );
  }

  void _openCreateEvent() {
    showDialog(
      context: context,
      builder: (context) => CreateEventDialog(
        nextId: 0,
        onCreate: (_) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _currentIndex == 0
            ? IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _openFilterModal,
              )
            : null,
        title: const Text('Home'),
        centerTitle: true,
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onAddPressed: _openCreateEvent,
      ),
    );
  }
}