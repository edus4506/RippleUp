import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'profile_page.dart';
import 'events_page.dart';
import 'create_event_page.dart';
import 'direct_messages_page.dart';
import 'discover_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const EventsPage(),
    const DiscoverPage(),
    const DirectMessagesPage(),
    const ProfilePage(),
  ];

  void _openCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
